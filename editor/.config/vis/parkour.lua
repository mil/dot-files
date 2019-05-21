-- parkour.lua --- structural editing plugin for Vis
--
-- Copyright © 2018-2019 Georgi Kirilov <kirilov.georgi.s@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

require("vis")

local vis = vis

local l = vis.lpeg

local M = {
	motion = {}, textobject = {}, operator = {},
	insert = {
		backward_delete = "<Backspace>", forward_delete = "<Delete>", backward_kill_word = "<C-w>", backward_kill_line = "<C-u>",
		backward_word = "<S-Left>", forward_word = "<S-Right>",
	},
	map = {
		prev_begin = "b", next_begin = "w", prev_end = "ge", next_end = "e",
		prev_sexp = false, next_sexp = false, prev_start = "<S-Left>", next_finish = "<S-Right>",
		prev_opening = "B", next_opening = "W", prev_closing = "gE", next_closing = "E",
		backward_up = "(", forward_up = ")", backward_down = "<", forward_down = ">",
		prev_paragraph = "{", next_paragraph = "}",
		prev_section = "[[", next_section = "]]",
		search_word_forward = "*", search_word_backward = "#",
		match_pair_inclusive = false,
		match_pair = false,
		outer_sexp = "aw", inner_sexp = "iw",
		outer_form = {"aW", "ab"}, inner_form = {"iW", "ib"},
		outer_paragraph = "ap", inner_paragraph = "ip",
		outer_line = "al", inner_line = "il",
		outer_comment = "as", inner_comment = "is",
		outer_string = 'a"', inner_string = 'i"',
		outer_escaped = false,
		delete = "d", change = "c", yank = "y", put_after = "p", put_before = "P",
		wrap_round = "gw", meta_doublequote = 'g"', raise_sexp = "gr",
		repl_send = "<Enter>", format = "=",
	},
	equalprg = {},
	repl_fifo = nil,
	autoselect = false,
	syntax = {lisp = true, scheme = true, clojure = true},
}


local tabwidth = 2

-- cached offsets of interest, sorted
local sexps, pb, sb, se, ebs, eb, ee, wb, we, pWB, WB, WE, ub, ue

-- cached file content
local content

-- whether unmatched brackets have been found during parsing
local unbalanced

-- the offset of the last repaired *closing* bracket;
-- used when the repair was undone, to force a far parse, so the unbalanced flag can be set again.
-- it's only good if the undo was performed immediately after the repair.
local last_repaired

-- the last file offset that has been parsed and cached
local first_invalid

-- maximum look-behind length for reader macro prefixes - `(, ,@(, #u8(, etc.
-- this is only used during input in insert mode
local PREFIX_MAXLEN = 5

-- file handle used for sending code to a REPL
local repl_fifo

-- a hint to some operators and motions that they've been called from insert mode
-- vis.mode can't be used, vis always sets it to OPERATOR_PENDING
local insert

-- for objectwise pasting (like yy/dd/cc, but for objects other than lines)
local last_object_type
local last_object_yanked

-- whether vis.win.syntax is a kind of Lisp; some features only make sense in Lisps
local a_lisp

-- IDs of built-in motions and textobjects used in the plugin (copied from vis.h)
local VIS_MOVE_LINE_DOWN = 0
local VIS_MOVE_LINE_UP = 1
local VIS_MOVE_LINE_BEGIN = 8
local VIS_MOVE_LINE_START = 9
local VIS_MOVE_LINE_END = 12
local VIS_MOVE_CHAR_PREV = 16
local VIS_MOVE_CHAR_NEXT = 17
local VIS_MOVE_PARAGRAPH_PREV = 34
local VIS_MOVE_PARAGRAPH_NEXT = 35
local VIS_MOVE_FILE_BEGIN = 49
local VIS_MOVE_FILE_END = 50
local VIS_MOVE_WINDOW_LINE_TOP = 55
local VIS_MOVE_WINDOW_LINE_MIDDLE = 56
local VIS_MOVE_WINDOW_LINE_BOTTOM = 57
local VIS_MOVE_NOP = 60
local VIS_MOVE_PERCENT = 61
local VIS_TEXTOBJECT_PARAGRAPH = 5
local VIS_TEXTOBJECT_PARAGRAPH_OUTER = 6
local VIS_TEXTOBJECT_OUTER_LINE = 23

local I = l.Cp()
local space = l.S" \t\n\v"

-- language-specific tokens, borrowed from vis.lexers and set on WIN_OPEN
local d1, d2, D2
local C, Str, Op, atom, word

-- these functions push the various offsets of interest into the cache data structures
local function p(list) return l.Cc(list) * I / table.insert end
local function P(list) return p(list) * I end
local function insert1(list, pos) table.insert(list, pos - 1) end
local function p1(list) return l.Cc(list) * I / insert1 end
local function pt(list, tbl) return l.Cc(list) * tbl / table.insert end
local function sparse_insert(k, v, list)
	-- results in a sparse list; by looking up the offset of a `(`,
	-- the offset of its reader macro prefix is found in O(1) time.
	-- the [0] marks the list as sparse, so functions that can take
	-- both sequential and sparse tables can handle each appropriately
	if not list[0] then list[0] = true end
	list[k] = v
end
local function insert_at(prefix_pos, pos, prefix_list, list)
	table.insert(list, pos)
	if prefix_pos < pos then
		sparse_insert(pos, prefix_pos, prefix_list)
	end
	return pos
end
local function Pm(prefix_list, list) return I * Op^0 * I * l.Cc(prefix_list) * l.Cc(list) / insert_at end
local function Ps(patt, list) return I * patt * I * l.Cc(list) / sparse_insert end

-- binary search a cache for the nearest offset before pos
local function before(t, pos)
	local left, right = 1, #t
	while right >= 1 and left <= #t do
		local m = bit32.rshift(left + right, 1)
		if pos > t[m] and (m == #t or pos <= t[m + 1]) then return t[m], m end
		if pos <= t[m] then right = m - 1 else left = m + 1 end
	end
end

-- binary search a cache for the nearest offset after pos
local function after(t, pos)
	local left, right = 1, #t
	while right >= 1 and left <= #t do
		local m = bit32.rshift(left + right, 1)
		if pos < t[m] and (m == 1 or pos >= t[m - 1]) then return t[m], m end
		if pos < t[m] then right = m - 1 else left = m + 1 end
	end
end

-- structure-sharing take-while!
local function take_while(pred, list)
	if list[0] then  -- if sparse, we can't do numeric for
		for k in pairs(list) do
			if not pred(k) then
				list[k] = nil
			end
		end
	else  -- if sequential, by working backwards we can stop early
		for i = #list, 1, -1 do
			if not pred(list[i]) then
				table.remove(list)
			else
				break
			end
		end
	end
	return list
end

local function past(_, position, pos)
	return position <= pos
end

local function unique(list)  -- luacheck: ignore
	for i = 1, #list do
		for j = i + 1, #list do
			if list[i] == list[j] then
				return nil, "duplicate entries: "..require'inspect'(list)
			end
		end
	end
	return true
end

local function sorted(list)  -- luacheck: ignore
	for i = 1, #list - 1 do
		if list[i] > list[i + 1] then
			return nil, "unsorted entries: "..require'inspect'(list)
		end
	end
	return true
end

local function identical(incremental, full)  -- luacheck: ignore
	if not (incremental and full) then return false, "empty list(s)" end
	for i = 1, #incremental do
		if incremental[i] ~= full[i] then return false, "incremental parsing differs from a full parse:\n"..require'inspect'(incremental).."\n"..require'inspect'(full) end
	end
	return true
end

local function get_horizons(text)  -- luacheck: ignore
	local horizons = {}
	local pattern = l.P{p(horizons) * l.P{l.Ct(Op^0 * d1 * ((C + Str + atom) + 1 - Op^0 * d1 - d2 + l.V(1))^0 * d2)} + (p(horizons) * (C + Str + atom)) + (d1 + D2) + l.P"\f" * l.P"\n"^1 + space^1}
	l.P(pattern^0):match(text)
	return horizons
end

-- the main parsing function.
-- it works incrementally, in units of top-level S-expressions (paragraphs).
-- a "sliding horizon" is used for that purpose - the beginnings of all parsed paragraphs are cached,
-- occassionally some of them are purged, and any parsing happens from the last one onwards.
-- for files that have only few, or even one, but big, "paragraph", like SXML,
-- this way of incrementing doesn't help much, if at all.
local function get_sexps(win, advance)
	local base
	if first_invalid then
		if advance >= 0 then
			base = before(pb, first_invalid + 2)
		else
			base = first_invalid + 1
		end
	end
	if not base then
		sexps, pb, sb, se, ebs, eb, ee, wb, we, pWB, WB, WE, ub, ue = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
	elseif first_invalid + 1 >= base and advance >= 0 then
		-- extend the parsing range to the nearest unmatched closing delimiter
		-- without this, once it's been purged from the cache the unbalanced flag could not be set again
		if #ue > 0 then
			local nearest_ue = after(ue, advance)
			if nearest_ue then advance = nearest_ue - 1 end
		end
		-- purge all caches from entries with a start offset higher than base.
		-- this is usually done right after a change in the file;
		-- entries with a start offset lower than that of the change are still good to use.
		take_while(function(e) return e[1] < base end, sexps)
		for _, list in ipairs({pb, sb, se, ebs, eb, ee, wb, we, pWB, WB, WE, ub, ue}) do
			take_while(function(e) return e < base end, list)
		end
	end
	local pattern = l.P{p(pb) * pt(sexps, l.P{l.Ct(Pm(pWB, WB) * d1 * (p(wb) * (p(eb) * (C + Ps(Str, ebs)) * p1(ee) + atom) * p1(we) + 1 - Op^0 * d1 - d2 + l.V(1))^0 * P(WE) * d2)}) + (p(pb) * p(wb) * (p(eb) * (C + Ps(Str, ebs)) * p1(ee) + atom) * p1(we)) + (p(ub) * p(WB) * d1 + p(ue) * p(WE) * D2) + (p(se) * l.P"\f" * l.P"\n"^1 * p1(sb)) + space^1}
	content = win.file:content(0, win.file.size)
	if advance < 0 then
		first_invalid = l.P(pattern^advance):match(content, base) - 1
	else
		first_invalid = l.P((l.Cmt(l.Cc(advance + 1), past) * pattern)^0):match(content, base) - 1
	end
	unbalanced = #ub > 0 or #ue > 0
	--assert(unique(pb))
	--assert(sorted(pb))
	--assert(identical(pb, get_horizons(content)))
	--assert(#eb == #ee, "#escaped-begins ~= #escaped-ends")
	--assert(#wb == #we, "#word-begins ~= #word-ends")
end

-- handler functions for vis motions, textobjects, operators, and insert mode mappings
local H = {M = {}, T = {}, O = {}, I = {}}

function H.M.prev_begin(_, pos, estart, efinish)
	local newpos
	if estart and efinish then
		newpos = l.P{l.Ct(((1 - word)^0 * I * l.Cmt(l.Cc(pos), past) * word)^0)}:match(content, estart + 2)
		if newpos then newpos = newpos[#newpos] end
		if not newpos then pos = estart end
	end
	if not newpos then
		newpos = before(wb, pos + 1)
	end
	return newpos and newpos - 1 or 0, true  -- See [avalanche-trick]
end

function H.M.next_begin(_, pos, estart, efinish)
	local newpos
	if estart then
		newpos = l.P{(1 - word) * I * word + l.Cmt(1 * l.Cc(efinish + 1), past) * l.V(1)}:match(content, pos + 1)
		if not newpos then pos = efinish end
	end
	if not newpos then
		newpos = after(wb, pos + 1)
	end
	return newpos and newpos - 1 or pos
end

function H.M.prev_end(_, pos, estart, efinish)
	local newpos
	if estart and efinish then
		newpos = l.P{l.Ct(((1 - word)^0 * word * I * l.Cmt(l.Cc(pos + 1), past))^0)}:match(content, estart + 2)
		if newpos then newpos = newpos[#newpos] end
		if not newpos then pos = estart else newpos = newpos - 1 end
	end
	if not newpos then
		newpos = before(we, pos + 1)
	end
	return newpos and newpos - 1 or pos, true  -- See [avalanche-trick]
end

function H.M.next_end(_, pos, estart, efinish)
	local newpos
	if estart then
		newpos = l.P{word * I + l.Cmt(1 * l.Cc(efinish + 1), past) * l.V(1)}:match(content, pos + 2)
		if not newpos then pos = efinish else newpos = newpos - 1 end
	end
	if not newpos then
		newpos = after(we, pos + 1)
	end
	return newpos and newpos - 1 or pos
end

function H.M.prev_opening(_, pos)
	local newpos = before(WB, pos + 1)
	return newpos and newpos - 1 or pos, true  -- See [avalanche-trick]
end

function H.M.next_opening(_, pos)
	local newpos = after(WB, pos + 1)
	return newpos and newpos - 1 or pos
end

function H.M.prev_closing(_, pos)
	local newpos = before(WE, pos + 1)
	return newpos and newpos - 1 or pos, true  -- See [avalanche-trick]
end

function H.M.next_closing(_, pos)
	local newpos = after(WE, pos + 1)
	return newpos and newpos - 1 or pos
end

function H.M.prev_start(win, pos, estart, efinish)
	local prev_opening = H.M.prev_opening(win, pos)
	local prev_begin = H.M.prev_begin(win, pos, estart, efinish)
	prev_opening = estart or prev_opening
	return (prev_opening == pos or prev_opening < prev_begin) and prev_begin or prev_opening
end

function H.M.next_finish(win, pos, estart, efinish)
	local next_closing = H.M.next_closing(win, pos)
	local next_end = H.M.next_end(win, pos, estart, efinish)
	next_closing = efinish or next_closing
	-- the + 1 is because it's more convenient to do C-w afterwards (and to mimic Emacs M-f)
	return (next_closing == pos or next_closing > next_end) and next_end + 1 or next_closing
end

function H.M.prev_sexp(win, pos)
	local prev_closing = H.M.prev_closing(win, pos)
	local prev_end = H.M.prev_end(win, pos)
	local nearest_finish = (prev_closing == pos or prev_closing < prev_end and prev_end < pos) and prev_end or prev_closing
	local start = H.T.inner_form(win, pos)
	local pstart = H.M.backward_up(win, pos, nil, nil, nil, 2)
	-- don't slurp from higher levels
	if start and pos + 1 == start and pstart < pos and nearest_finish < pstart then return pos, true end  -- See [avalanche-trick]
	-- don't barf from empty form
	return not (start and pos >= start and nearest_finish < start) and nearest_finish or pos, true  -- See [avalanche-trick]
end

function H.M.next_sexp(win, pos)
	local next_opening = H.M.next_opening(win, pos)
	local next_begin = H.M.next_begin(win, pos)
	local nearest_start = (next_opening == pos or next_opening > next_begin and next_begin > pos) and next_begin or next_opening
	local _, finish = H.T.inner_form(win, pos)
	local pfinish = H.M.forward_up(win, pos, nil, nil, 0, 2)
	-- don't slurp from higher levels
	if finish and pos == finish and pfinish > pos and nearest_start > pfinish then return pos, true end  -- See [avalanche-trick]
	-- don't barf from empty form
	return not (finish and pos < finish and nearest_start > finish) and nearest_start or pos, (finish and pos < finish and nearest_start >= pos)  -- See [avalanche-trick]
end

-- binary search a cache list for the form that contains the offset given
-- XXX: margin is just a trick to make the function work on
-- both the sexps list - {{}, {}, {}}, and any of its children - {1, {}, {}, {}, 5}.
local function around(t, pos, margin)
	margin = margin or 0
	local left, right = 1, #t - margin * 2
	local last_m
	while right >= 1 and left <= #t - margin * 2 do
		local m = bit32.rshift(left + right, 1)
		if m == last_m then break else last_m = m end -- is there a better way to avoid an endless loop?
		local e = t[m + margin]
		if pos.start + 1 >= e[1] and pos.finish <= e[#e] then return e end
		if pos.start + 1 < e[1] then right = m - 1 else left = m + 1 end
	end
end

-- recursively search a cache tree for the count-th innermost form that contains the offset given
local function form_around(t, pos, depth, count)
	if t and t[1] <= pos.start + 1 and t[#t] >= pos.finish then
		local start, finish, d
		local c = count
		if #t >= 3 then
			local child = around(t, pos, 1)
			if child then
				start, finish, d, c = form_around(child, pos, depth and depth + 1 or 1, count)
			end
		end
		if c then
			return t[1], t[#t], depth, c > 1 and c - 1 or nil
		end
		return start, finish, d
	end
end

local function selection_by_pos(win, pos)
	for selection in win:selections_iterator() do
		if selection.pos == pos and pos < win.file.size then
			return selection
		end
	end
end

local function form_at(pos, count)
	-- TODO: instead of converting from 0-based to 1-based positions here,
	-- accept and return 0-based only.
	local sel = selection_by_pos(vis.win, pos - 1)
	sel = sel and sel.range or {start = pos - 1, finish = pos}
	return form_around(around(sexps, sel), sel, nil, count or 1)
end

function H.M.backward_up(_, pos, estart, _, _, count)
	if estart then
		return estart
	else
		local start, finish = form_at(pos + 1, count)
		return start and pos + 1 < finish and start - 1 or pos
	end
end

function H.M.forward_up(win, pos, _, efinish, exclusivity, count)
	if efinish then
		return efinish - 1 + exclusivity
	else
		local sstart, sfinish = H.T.outer_string(win, pos)
		if sstart and pos + 1 == sfinish and exclusivity > 0 then
			return sfinish - 1 + exclusivity
		end
		local start, finish = form_at(pos + 1, count)
		return finish and (pos + 1 > start) and finish - 1 + exclusivity or pos
	end
end

function H.M.backward_down(_, pos, _, _, _, count)
	local start, _, d = form_at(pos + 1, count)
	local prev_closing = before(WE, pos + 1)
	if prev_closing and (not start or prev_closing > start) then
		local _, _, prev_d = form_at(prev_closing, count)
		if (prev_d or d or 0) >= (d or 0) then
			return prev_closing - 1
		end
	end
	return pos, true  -- See [avalanche-trick]
end

function H.M.forward_down(_, pos, _, _, _, count)
	local _, finish, d = form_at(pos + 1, count)
	local next_opening = after(WB, pos + 1)
	if next_opening and (not finish or next_opening < finish) then
		local _, _, next_d = form_at(next_opening, count)
		if (next_d or d or 0) >= (d or 0) then
			return next_opening - 1
		end
	end
	return pos, finish  -- See [avalanche-trick]
end

function H.M.prev_paragraph(_, pos)
	local newpos = before(pb, pos + 1)
	return newpos and newpos - 1 or 0, true  -- See [avalanche-trick]
end

function H.M.next_paragraph(_, pos)
	local newpos = after(pb, pos + 1)
	return newpos and newpos - 1 or pos
end

function H.M.prev_section(_, pos)
	local newpos = before(sb, pos)
	return newpos or 0, true  -- See [avalanche-trick]
end

function H.M.next_section(_, pos)
	local newpos = after(sb, pos + 1)
	return newpos or pos
end

local function skip_prefix(pos)
	for k, v in pairs(pWB) do
		if v == pos then return k end
	end
	return pos
end

function H.M.search_word_forward(win, pos, estart, efinish)
	local start, finish = H.T.outer_sexp(win, pos, estart, efinish)
	if not (start and finish) then return pos end
	local cword = l.P(content:sub(start + 1, finish))
	local B, E = (1 - atom - Op), (1 - atom)
	local newpos = l.P{B * I * cword * #E + 1 * l.V(1)}:match(content, finish + 1)
	return newpos and skip_prefix(newpos) - 1 or pos
end

local function keep_last(_, cur)
	return cur
end

function H.M.search_word_backward(win, pos, estart, efinish)
	local start, finish = H.T.outer_sexp(win, pos, estart, efinish)
	if not (start and finish) then return pos end
	local cword = l.P(content:sub(start + 1, finish))
	local B, E = (1 - atom - Op), (1 - atom)
	local newpos = l.P{l.Cf(((1 - B * cword * #E)^0 * B * I * cword * #E * l.Cmt(l.Cc(pos + 1), past))^1, keep_last)}:match(content)
	return newpos and skip_prefix(newpos) - 1 or pos
end

function H.M.match_pair(win, pos)
	local start, finish = H.T.inner_string(win, pos)
	if not start then
		start, finish = H.T.inner_form(win, pos)
	end
	if pos == finish then
		return start - 1
	elseif pos + 1 == start then
		return finish
	end
	return pos, true  -- See [avalanche-trick]
end

function H.T.outer_form(_, pos, _, _, _, count)
	local start, finish, d = form_at(pos + 1, count)
	start = pWB[start] or start
	if start then return start - 1, finish, d end
end

function H.T.inner_form(_, pos, _, _, _, count)
	local start, finish, d = form_at(pos + 1, count)
	if start then return start, finish - 1, d end
end

local function at_pos(_, position, start, finish, pos)
	if pos >= start and pos < finish then
		return position, start - 1, finish - 1
	end
end

local function atom_at(pos)
	local start, nstart = before(wb, pos + 1)
	if start and pos >= start and pos <= we[nstart] then
		return start - 1, we[nstart]
	end
end

function H.T.outer_sexp(win, pos, estart, efinish)
	if estart and efinish then
		local start, finish = l.P{l.Cmt(I * word * I * l.Cc(pos + 1), at_pos) + l.Cmt(1 * l.Cc(pos + 1), past) * l.V(1)}:match(content, estart + 2)
		return start, finish
	end
	local start, finish = atom_at(pos + 1)
	if start then return start, finish end
	start, finish = H.T.inner_form(win, pos)
	if start and (pos + 1 == start or pos == finish) then
		return (pWB[start] or start) - 1, finish + 1
	end
end

function H.T.inner_sexp(win, pos, estart, efinish)
	if estart and efinish then
		local start, finish = l.P{l.Cmt(I * word * I * l.Cc(pos + 1), at_pos) + l.Cmt(1 * l.Cc(pos + 1), past) * l.V(1)}:match(content, estart + 2)
		return start, finish
	end
	local start, finish = atom_at(pos + 1)
	if start then return start, finish end
	start, finish = H.T.inner_form(win, pos)
	if start and (pos + 1 == start or pos == finish) then
		return start, finish
	end
end

function H.T.outer_paragraph(win, pos)
	local start = H.M.prev_paragraph(win, pos + 1)
	if start then
		local _, finish = H.T.outer_sexp(win, skip_prefix(start + 1) - 1)
		local nue = after(ue, finish)
		local nub = after(ub, finish)
		local nse = after(se, finish)
		-- extend the range to include the trailing whitespace, but only
		-- if there are no unmatched parentheses between the two paragraphs.
		local np = H.M.next_paragraph(win, pos)
		if not (nue or nub or nse) or nue and nue > np or nub and nub > np then
			finish = np
		elseif nse then
			finish = nse - 1
		elseif nub then
			finish = nub - 1
		elseif nue then
			finish = nue - 1
		end
		return start, finish > pos and finish or first_invalid
	end
end

function H.T.inner_paragraph(win, pos)
	local start = H.M.prev_paragraph(win, pos + 1)
	if start then
		return H.T.outer_sexp(win, skip_prefix(start + 1) - 1)
	end
end

function H.T.outer_line(win, pos)
	local sel = selection_by_pos(win, pos)
	if not sel then return end
	local line_start = pos - sel.col + 1
	local line_finish = line_start + #win.file.lines[sel.line]
	return line_start, line_finish + 1
end

function H.T.inner_line(win, pos)
	local sel = selection_by_pos(win, pos)
	if not sel then return end
	local _, indent = win.file.lines[sel.line]:find("^[ \t]*")
	local line_start = pos - sel.col + 1
	local line_finish = line_start + #win.file.lines[sel.line]
	return line_start + indent, line_finish
end

-- either a string or a comment
function H.T.outer_escaped(_, pos)
	local start, finish, n
	start, n = before(eb, pos + 1)
	if start and pos + 1 >= start and pos + 1 <= ee[n] then
		return start - 1, ee[n]
	else
		finish, n = after(ee, pos + 1)
		if finish and pos + 1 < finish and pos + 1 >= eb[n] then
			return eb[n] - 1, finish
		end
	end
end

function H.T.outer_string(win, pos)
	local start, finish = H.T.outer_escaped(win, pos)
	if start and ebs[start + 1] then
		return start, finish
	end
end

function H.T.inner_string(win, pos)
	local start, finish = H.T.outer_string(win, pos)
	if start and finish then
		return start + 1, finish - 1
	end
end

function H.T.outer_comment(win, pos)
	local start, finish = H.T.outer_escaped(win, pos)
	if start and not ebs[start + 1] then
		return start, finish
	end
end

H.T.inner_comment = H.T.outer_comment

-- XXX: this textobject is used as motion,
-- so when % jumps backwards the closing delimiter is included in the range.
function H.T.match_pair_inclusive(win, pos)
	local start, finish = H.T.inner_string(win, pos)
	if not start then
		start, finish = H.T.inner_form(win, pos)
	end
	if pos == finish or pos + 1 == start then
		return start - 1, finish + 1
	end
end

local function delete(file, range)
	file:delete(range)
end

local function change(file, range)
	file:delete(range)
end

-- either suppresses deleting a delimiter of a form, or deletes both its delimiters
-- returns the delimiters so the cursor knows how long to jump to skip them,
-- or, if deleted both, the delete operator knows what to put in a register.
local function splice(file, pos, start, finish, action)
	local spliced
	local op = pWB[start + 1] or start + 1
	local on_closing = pos == finish - 1 and 1
	local empty = finish - start == 2
	local opening = file:content(op - 1, start - op + 2)
	local closing = file:content(finish - 1, 1)
	if start and (on_closing or pos >= start) and (not insert or empty) then
		if action == delete then
			file:delete(finish - 1, 1)
			file:delete(op - 1, start - op + 2)
			spliced = true
			first_invalid = op - 1
		end
	end
	return spliced, opening, closing
end

-- find intersections of the kill range with forms that only partially fall in it.
local function overlap(t, range)
	if #t >= 3 then
		if (t[1] < range.start + 1 and t[#t] >= range.finish or t[1] < range.start + 1 and t[#t] > range.start or t[#t] >= range.finish and t[1] < range.finish + 1 or t[#t] == 0) then
			for i = 2, #t - 1 do
				local r = overlap(t[i], range)
				if r then
					coroutine.yield(r)
				end
			end
			if t[1] < range.start + 1 and t[#t] > range.start and t[#t] <= range.finish then
				coroutine.yield(t[#t])
			elseif t[1] < range.finish + 1 and t[1] >= range.start + 1 and t[#t] > range.finish then
				coroutine.yield(t[1])
			end
		end
	elseif not (t[1] < range.start + 1 and t[#t] > range.finish) then
		if t[1] < range.start + 1 and t[#t] > range.start and t[#t] <= range.finish then
			coroutine.yield(t[#t])
		elseif t[#t] > range.finish and t[1] < range.finish + 1 then
			coroutine.yield(t[1])
		end
	end
end

-- checks if the offset given falls within a comment or a string, and returns its range
local function escaped(pos, win)
	if pos >= first_invalid then get_sexps(win, pos) end
	local start, nstart = before(eb, pos + 1)
	local adj = (vis.mode == vis.modes.INSERT or insert) and 0 or 1  -- without this, an empty string/comment in insert mode will never match
	if start and pos + 1 > start and pos + 1 <= ee[nstart] - adj then
		return start - 1, ee[nstart]
	end
end

local opposite = {
	["("] = ")",
	[")"] = "(",
	["{"] = "}",
	["}"] = "{",
	["["] = "]",
	["]"] = "[",
	['"'] = '"',
}

-- finds any parens/quotes in the operator range whose matches are not in the range,
-- splits the range at these positions,
-- and applies the operator's action on each region.
local function pick_out(file, range, pos, action, copy)
	if range.finish == range.start then return range.start end
	if first_invalid and range.finish >= first_invalid then
		get_sexps(vis.win, range.finish)
	end
	local slice_at = coroutine.wrap(overlap)
	local skips = {}
	local splice_at
	table.insert(sexps, 0)
	table.insert(sexps, 1, 0)
	repeat
		local slice_pos = slice_at(sexps, range)
		if slice_pos then table.insert(skips, slice_pos) end
	until not slice_pos
	table.remove(sexps)
	table.remove(sexps, 1)
	-- preserve double quotes, too. overlap() only takes care of brackets.
	local estart1, efinish1 = H.T.outer_string(vis.win, range.start)
	if efinish1 and estart1 < range.start and efinish1 <= range.finish
		-- XXX: #\char is technically a string, but no need to skip over # and r, they are not quotes:
		and content:sub(estart1 + 1, estart1 + 1) == opposite[content:sub(efinish1, efinish1)] then
		table.insert(skips, efinish1)
	else
		estart1, efinish1 = nil, nil
	end
	local estart2, efinish2 = H.T.outer_string(vis.win, range.finish)
	if estart2 and estart2 < range.finish and estart2 >= range.start
		-- XXX: #\char is technically a string, but no need to skip over # and r, they are not quotes:
		and content:sub(estart2 + 1, estart2 + 1) == opposite[content:sub(efinish2, efinish2)] then
		table.insert(skips, estart2 + 1)
	else
		estart2, efinish2 = nil, nil
	end
	local slicing = #skips > 0
	local backwards = pos == range.finish
	local visual = vis.mode == vis.modes.VISUAL
	local multisel = visual and #vis.win.selections > 1
	-- handle splice and kill-splice of forms and strings:
	if #skips == 1 and not multisel then
		local start, finish
		if not (estart1 or efinish2) then
			start, finish = H.T.inner_form(vis.win, skips[1] - 1)
			start = start - 1
			finish = finish + 1
		elseif estart1 then
			start, finish = estart1, efinish1
		elseif efinish2 then
			start, finish = estart2, efinish2
		end
		local backward_splice = start and range.start == start and range.start + 1 == skips[1]
		local forward_splice = finish and range.finish == finish and range.finish == skips[1]
		if (backward_splice and (backwards or visual) or forward_splice and (not backwards or visual))
			-- XXX: #\" is technically a string, but we better not splice it:
			and content:sub(start + 1, start + 1) == opposite[content:sub(finish, finish)] then
			splice_at = {start, finish}
		end
		if insert and not (start + 2 == finish)
			and (backward_splice and backwards and pos == skips[1]
			or forward_splice and not backwards and pos + 1 == skips[1]) then
			return pos
		end
	end
	table.sort(skips)
	table.insert(skips, range.finish + 1)
	table.insert(skips, 1, range.start)
	local scraps = copy and ""
	local ndeleted = 0
	for i = #skips - 1, 1, -1 do
		local region = {start = skips[i], finish = (slicing and pWB[skips[i + 1]] or skips[i + 1]) - 1}
		local len = region.finish - region.start
		if len > 0 then
			local esstart, esfinish = escaped(region.start, vis.win)
			local efstart, effinish = escaped(region.finish - 1, vis.win)
			if esstart and esfinish and efstart and effinish and esstart == efstart then
				-- extend the kill range if it only partially covers a backslashed character:
				if H.T.outer_string(vis.win, esstart) == esstart then
					if file:content(region.start - 1, 2):match('\\.') then
						region.start = region.start - 1
						range.start = range.start - (backwards and 1 or 0)
					end
					if file:content(region.finish - 1, 2):match('\\.') then
						region.finish = region.finish + 1
					end
					len = region.finish - region.start
				end
			end
			-- remember the deleted content for later storing into a register
			scraps = scraps and file:content(region) .. scraps
			if action then
				-- clean trailing and/or leading whitespace separators, depending on the situation
				if action == delete then
					-- XXX: outer_sexp is called at both ends in case the region consists of multiple whole sexps
					local sstart = H.T.outer_sexp(vis.win, region.start)
					local _, sfinish = H.T.outer_sexp(vis.win, region.finish - 1)
					local is_sexp = sstart == region.start and sfinish == region.finish
					local fstart, ffinish = form_at(region.finish + 1)
					local pfinish = H.M.prev_sexp(vis.win, region.start)
					pfinish = pfinish < region.start and pfinish
					local nstart = H.M.next_sexp(vis.win, region.finish)
					nstart = (pWB[nstart + 1] and pWB[nstart + 1] - 1) or nstart
					local nopening = H.M.next_sexp(vis.win, region.finish - 1)
					local partial_prefix
					if nopening and pWB[nopening + 1] then
						partial_prefix = region.start >= pWB[nopening + 1] - 1
					end
					local last_in_form = sstart == region.start and (nstart == region.finish or ffinish and nstart > ffinish) and (sfinish or ffinish and region.finish + 1 == ffinish)
					local last_on_line = nstart > region.finish and 1 == file:content(region.finish, nstart - region.finish):find("\n")
					local first_on_line = pfinish and 1 == file:content(pfinish + 1, region.start - pfinish):find("\n")
					if last_in_form then
						if pfinish and fstart and pfinish > fstart and not (insert and first_on_line) then
							if not sfinish or region.finish >= sfinish then
								region.start = pfinish + 1
								region.finish = ffinish - 1
							end
							range.start = region.start - ((visual or insert or not last_object_type) and 0 or 1)
						end
					elseif is_sexp then
						if nstart and ffinish and nstart < ffinish and nstart > fstart and not last_on_line then
							region.finish = nstart
							range.start = region.start - (visual and 1 or 0)
						elseif pfinish and fstart and pfinish > fstart then
							region.start = pfinish + 1
							range.start = region.start - ((visual or insert) and 0 or 1)
						end
					elseif partial_prefix then
						region.start = pWB[nopening + 1] - 1
						region.finish = nopening
						range.start = region.start
					end
					len = region.finish - region.start
				end
				local start = action(file, region)
				if start then range.start = start end
				ndeleted = ndeleted + len
			end
		end
	end
	if ndeleted > 0 then first_invalid = range.start end
	if splice_at then
		last_object_yanked = H.T.outer_form
		splice_at[2] = splice_at[2] - ndeleted
		local spliced, opening, closing = splice(file, pos, splice_at[1], splice_at[2], visual or action)
		scraps = scraps and action ~= change and opening..scraps..closing or scraps
		if spliced then
			range.start = range.start - ((backwards or action == delete) and #opening or 0) + (backwards and 1 or 0)
			range.finish = range.finish - #opening - #closing
		elseif not visual then
			if not backwards then
				range.start = range.start + (action == delete and #closing or 0)
			else
				range.start = range.start - (action == delete and #opening or 0) + 1
			end
		end
	elseif vis.mode == vis.modes.VISUAL_LINE then
		last_object_yanked = H.T.outer_line
	else
		last_object_yanked = last_object_type
	end
	last_object_type = nil
	if slicing and action == change then
		range.start = range.start + ((splice_at and splice_at[1] == range.start) and 1 or 0)
	end
	if not insert and scraps then
		vis.registers[vis.register or '"'] = {scraps}
	end
	return (backwards or ndeleted ~= 0 or action ~= delete) and range.start or range.finish
end

H.O.delete = function (file, range, pos) return pick_out(file, range, pos, delete, true) end
H.O.yank = function (file, range, pos) return pick_out(file, range, pos, nil, true) end

local selections = 0

function H.O.change(file, range, pos)
	local newpos = pick_out(file, range, pos, change, true)
	if selections == 0 then
		selections = #vis.win.selections
	end
	selections = selections - 1
	if selections == 0 then
		vis.mode = vis.modes.INSERT
	end
	return newpos
end

local function wrap_round(file, range, _)
	local kind = "("
	file:insert(range.finish, opposite[kind])
	file:insert(range.start, kind)
	first_invalid = range.start
	return range.start + 1
end

H.O.wrap_round = function (file, range, pos) return pick_out(file, range, pos, wrap_round) end

local function meta_doublequote(file, range, _)
	local kind = '"'
	local escape = H.T.outer_string(vis.win, range.start) and "\\" or ""
	file:insert(range.finish, escape..opposite[kind])
	file:insert(range.start, escape..kind)
	first_invalid = range.start
	return range.start + #(escape..kind)
end

H.O.meta_doublequote = function (file, range, pos) return pick_out(file, range, pos, meta_doublequote) end

function H.O.raise_sexp(file, range, pos)
	if range.finish == range.start then return pos end
	local fstart, ffinish = H.T.inner_form(vis.win, range.finish)
	if fstart and ffinish then
		-- XXX: delete, but without copying to a register
		pick_out(file, {start = range.finish, finish = ffinish}, range.finish, delete)
		get_sexps(vis.win, pos)
		pos = pick_out(file, {start = fstart - 1, finish = range.start}, range.start, delete)
		get_sexps(vis.win, fstart - 1)
	end
	return pos
end

function H.O.repl_send(file, range, pos)
	if not M.repl_fifo or range.finish == range.start then return pos end
	if pos > range.finish then return pos end
	local errmsg
	if not repl_fifo then
		repl_fifo, errmsg = io.open(M.repl_fifo, "a+")
	end
	if repl_fifo then
		repl_fifo:write(file:content(range), "\n")
		repl_fifo:flush()
	elseif errmsg then
		vis:info(errmsg)
	end
	return pos
end

function H.O.format(file, range, pos)
	if not M.equalprg[vis.win.syntax] or range.finish == range.start then return pos end
	local status, out = vis:pipe(file, range, M.equalprg[vis.win.syntax])
	local selection = selection_by_pos(vis.win, pos)
	if not selection then return end
	selection.pos = range.start
	local indent = selection.col - 1
	selection.pos = pos
	local raised = file:content(range):gsub("\n"..(" "):rep(indent), "\n")
	out = out and out:gsub("\n$", "")
	if status == 0 and out and raised ~= out then
		file:delete(range)
		out = out:gsub("\n", "\n"..(" "):rep(indent))
		file:insert(range.start, out)
		first_invalid = range.start
		-- XXX: if the form was reformatted, there is no single, generic way to restore the cursor position. [1]
		-- Between the start and the new finish, I chose the finish because that's where ) needs to jump (in INSERT mode).
		-- (I can't just use forward-up because, after reformatting, the cursor might not even be at the same depth.)
		-- A positive role of changing the cursor position is to serve as a flag that reformatting actually happened:
		-- [1] TODO: the following might work:
		-- * find the position N of the current/next sexp in the form (in sexps, not characters), and the cursor position P
		--   relative to its beginning.
		-- * after reformatting, pos = N * H.M.next_sexp + P
		-- This would work even with aggressive formatters that wrap lines.
		return range.start + #out - 1
	end
	return pos
end

local function textobject_includes_separator(object_type)
	return ({[H.T.outer_line] = true, [H.T.inner_line] = true, [H.T.outer_paragraph] = true, [H.T.inner_paragraph] = true})[object_type]
end

function H.O.put_after(file, range, pos)
	first_invalid = pos
	local visual = not M.autoselect and ({[vis.modes.VISUAL] = true, [vis.modes.VISUAL_LINE] = true})[vis.mode]
	if visual then
		-- XXX: like H.O.delete(), but without overwriting the register content
		pos = pick_out(file, range, pos, delete)
	end
	local on_object = not visual and (range.start < range.finish)
	if on_object and pos + 1 < range.finish then
		pos = range.finish - (({[H.T.outer_line] = 0, [H.T.outer_paragraph] = 0})[last_object_yanked] or 1)
	end
	local needs_separator = not visual and not textobject_includes_separator(last_object_yanked)
	pos = pos + (needs_separator and 1 or 0)
	file:insert(pos, ((on_object and needs_separator) and " " or "") .. vis.registers[vis.register or '"'][1])
	return pos + ((on_object and needs_separator) and 1 or 0)
end

function H.O.put_before(file, range, pos)
	first_invalid = pos
	local visual = not M.autoselect and ({[vis.modes.VISUAL] = true, [vis.modes.VISUAL_LINE] = true})[vis.mode]
	if visual then
		-- XXX: like H.O.delete(), but without overwriting the register content
		pos = pick_out(file, range, pos, delete)
	end
	local on_object = not visual and (range.start < range.finish)
	if on_object and pos > range.start then
		pos = range.start
	end
	local needs_separator = not visual and not textobject_includes_separator(last_object_yanked)
	local clipboard = vis.registers[vis.register or '"'][1] .. ((on_object and needs_separator) and " " or "")
	file:insert(pos, clipboard)
	return pos + ((on_object and needs_separator) and #clipboard or 0)
end

function H.I.backward_delete(win)
	local line = win.file.lines[win.selection.line]
	local col = win.selection.col - 1
	if line:sub(1, col):match("^[ \t]+$") then
		local remainder = col % tabwidth
		vis.count = remainder == 0 and tabwidth or remainder
	end
	vis:operator(M.operator.delete[vis.modes.NORMAL].id)
	vis:motion(VIS_MOVE_CHAR_PREV)
end

function H.I.forward_delete(_)
	vis:operator(M.operator.delete[vis.modes.NORMAL].id)
	vis:motion(VIS_MOVE_CHAR_NEXT)
end

function H.I.backward_kill_word(_)
	vis:operator(M.operator.delete[vis.modes.NORMAL].id)
	vis:motion(M.motion.prev_start[vis.modes.OPERATOR_PENDING].id)
end

function H.I.backward_kill_line(win)
	vis:operator(M.operator.delete[vis.modes.NORMAL].id)
	if win.selection.col == 1 then
		vis:motion(VIS_MOVE_CHAR_PREV)
	elseif win.file.lines[win.selection.line]:sub(1, win.selection.col - 1):match("^[ \t]+$") then
		vis:motion(VIS_MOVE_LINE_BEGIN)
	else
		vis:motion(VIS_MOVE_LINE_START)
	end
end

local function at(_, position, pos)
	return pos == position
end

local function insert_padded(delimiter, file, selection)
	local pos = selection.pos
	local lead, trail
	if a_lisp then
		local behind = pos - PREFIX_MAXLEN >= 0 and pos - PREFIX_MAXLEN or 0
		local op = l.P{I * (Op)^0 * l.Cmt(l.Cc(pos + 1 - behind), at) + 1 * l.V(1)}:match(file:content(behind, PREFIX_MAXLEN)) + behind
		lead = op > 1 and not (space + d1):match(file:content(op - 2, 1)) and (op - 1)
		trail = not (space + D2):match(file:content(pos, 1)) and pos < file.size
		-- when inserting, at top level, prefixed forms whose prefix is a valid atom,
		-- this lets the parser see both the prefix and the () as a single paragraph.
		first_invalid = op - 1
	end
	file:insert(pos, opposite[delimiter]..(trail and " " or ""))
	selection.pos = pos
	if lead then
		file:insert(lead, " ")
		selection.pos = pos + 1
	end
end

local function brackets(win, opening, selection)
	local pos = selection.pos
	if not escaped(pos, win) then
		local lone
		if unbalanced then
			lone = after(ue, pos)
			if lone and (form_at(lone) == form_at(pos)) then
				win.file:insert(pos, opposite[win.file:content(lone - 1, 1)])
				selection.pos = pos + 1
				first_invalid = win.selections[1].pos
				last_repaired = lone
			else
				lone = false
			end
		end
		if not lone then
			insert_padded(opening, win.file, selection)
		end
	end
end

local function doublequote(win, arg, selection)
	local pos = selection.pos
	first_invalid = pos
	local estart = escaped(pos, win)
	if estart then
		-- XXX: is it a string, or a comment:
		if arg == win.file:content(estart, 1) then
			if arg == win.file:content(pos, 1) then
				selection.pos = pos + 1
			else
				win.file:insert(pos, "\\"..arg)
				selection.pos = pos + 2
			end
		else
			win.file:insert(pos, arg)
			selection.pos = pos + 1
		end
	else
		insert_padded(arg, win.file, selection)
		pos = selection.pos
		win.file:insert(pos, arg)
		selection.pos = pos + 1
	end
	first_invalid = win.selections[1].pos
	return true
end

local function paragraphs_implemented(win)
	return ({scheme = true, lisp = true, clojure = true})[win.syntax]
end

-- XXX: math.max() doesn't work with nil arguments
local function max(...)
	local arguments = {}
	for _, v in pairs({...}) do
		table.insert(arguments, v)
	end
	table.sort(arguments)
	return arguments[#arguments]
end

local function last_finish_in_form(start, finish)
	local last_end = before(we, finish)
	local last_closing = before(WE, finish)
	return max(start, last_end, last_closing)
end

local function close(win, kind, selection)
	local pos = selection.pos
	get_sexps(win, pos)
	if escaped(pos, win) then
		win.file:insert(pos, kind)
		selection.pos = pos + 1
		first_invalid = win.selections[1].pos
	else
		local start, finish = form_at(pos + 1)
		if finish and D2:match(win.file:content(finish - 1, 1)) then
			local trailing = last_finish_in_form(start, finish)
			if selection.pos + 1 < finish then
				selection.pos = H.M.forward_up(win, pos, nil, nil, 0)
			end
			if trailing then
				local len = finish - trailing - 1
				pos = selection.pos
				win.file:delete(trailing, len)
				selection.pos = pos - len
				first_invalid = start - 1
			end
			if M.equalprg[win.syntax] and a_lisp then
				pos = selection.pos
				get_sexps(win, pos)
				local fstart, ffinish = H.T.outer_form(win, pos)
				-- FIXME: disaster when multiple cursors are in the same form
				local newpos = H.O.format(win.file, {start = fstart, finish = ffinish}, pos)
				selection.pos = newpos ~= pos and newpos or pos
			end
			selection.pos = selection.pos + 1
		elseif unbalanced then
			local lone = before(ub, pos + 1)
			if lone and (form_at(lone) == form_at(selection.pos + 1)) then
				win.file:insert(pos, opposite[win.file:content(lone - 1, 1)])
				selection.pos = pos + 1
				first_invalid = lone - 1
			end
		end
	end
	return true
end

local function newline(_, no_repl_send)
	local win = vis.win
	for i = #win.selections, 1, -1 do
		local selection = win.selections[i]
		local pos = selection.pos
		get_sexps(win, pos)
		local sstart = H.T.inner_string(win, pos)
		if sstart and pos + 1 > sstart then
			win.file:insert(pos, "\n")
			selection.pos = pos + 1
			first_invalid = win.selections[1].pos
		else
			local count
			local start, finish, depth = H.T.inner_form(win, pos)
			if start and pos + 1 == start then
				-- if the cursor was exactly on an opening bracket, the above call would return its bounds,
				-- but we are interested in the *current* form, which is its parent
				count = 2
				start, finish, depth = H.T.inner_form(win, pos, nil, nil, nil, count)
			end
			local trailing = start and l.P{I * l.P" "^1 * l.Cmt(l.Cc(finish + 1), at) + l.Cmt(1 * l.Cc(pos + 1), past) * l.V(1)}:match(content, start)
			local line = win.file.lines[selection.line]
			if M.repl_fifo and #line > 0 and not start and not no_repl_send then
				vis:operator(M.operator.repl_send[vis.modes.NORMAL].id)
				vis:textobject(M.textobject.inner_paragraph[vis.modes.OPERATOR_PENDING].id)
			end
			local autoindent = string.format("%"..((start and ((depth or 0) + ((start <= pos) and 1 or 0)) or 0) * tabwidth).."s", "")
			local at_form_end = start and ((trailing and pos + 1 >= trailing) or pos == finish)
			local leading = start and l.P{I * (l.Cmt(l.Cc(pos), past) * l.P" ")^1 * l.Cmt(l.Cc(pos + 1), at) + 1 * l.V(1)}:match(content, start + 1)
			if leading then
				win.file:delete(leading - 1, pos - leading + 1)
				selection.pos = leading - 1
			end
			pos = selection.pos
			local autoextend = ""
			if at_form_end then
				win.file:insert(pos, "\n"..autoindent)
				selection.pos = pos + 1 + #autoindent
			elseif M.comment then
				local indent_level, comment_level = line:match("^[ \t]*()("..M.comment.."+)[^"..M.comment.."]?")
				if comment_level and selection.col >= indent_level + #comment_level then
					autoextend = comment_level
				end
			end
			local fixeof = (pos == win.file.size and content:sub(pos, pos) ~= "\n") and "\n" or ""
			win.file:insert(pos, "\n"..autoindent..autoextend..fixeof)
			selection.pos = pos + 1 + #autoindent + #autoextend
			-- XXX: this must be before .format, so it gets the whole current form (with the "\n" and indentation):
			first_invalid = start or pos
			if M.equalprg[win.syntax] and start and a_lisp then
				get_sexps(win, selection.pos)
				local fstart, ffinish = H.T.outer_form(win, selection.pos, nil, nil, nil, count)
				-- FIXME: disaster when multiple cursors are in the same form
				H.O.format(win.file, {start = fstart, finish = ffinish}, selection.pos)
				first_invalid = start
				local _, indent = win.file:content(pos, win.file.size):find("^\n *")
				selection.pos = pos + (indent or 1) + #autoextend
			end
			if #autoextend > 0 then
				pos = selection.pos
				win.file:insert(pos, " ")
				selection.pos = pos + 1
				first_invalid = escaped(pos, win)
			end
		end
	end
end

function H.I.backward_word(_)
	vis:motion(M.motion.prev_start[vis.modes.NORMAL].id)
end

function H.I.forward_word(_)
	vis:motion(M.motion.next_finish[vis.modes.NORMAL].id)
end

local function comment(win, arg, selection)
	local pos = selection.pos
	first_invalid = win.selections[1].pos
	if not escaped(pos, win) then
		local start, finish = H.T.outer_sexp(win, pos)
		if not start then
			start = H.M.next_opening(win, pos)
			if start then
				start, finish = H.T.outer_sexp(win, start)
			end
		end
		local line = win.file.lines[selection.line]
		local col = selection.col
		local remaining = finish and line:sub(finish - pos + col)
		local last = remaining and (remaining:match("^[ \t]*$") or remaining:match("^[ \t]*"..arg))
		local datum = pos > 0 and "#" == win.file:content(pos - 1, 1)
		local first = line:sub(1, col - 1 - (datum and 1 or 0)):match("^[ \t]*$")
		local eol = col - 1 == #win.file.lines[selection.line] or selection.pos == win.file.size
		local multiline = start and win.file:content(start, finish - start):find("\n")
		local at_start = start and (not datum and start == pos) or datum -- this is wrong, but hopefully nobody will care about datum comments splitting an atom
		if not last and at_start and not multiline and (not datum or win.syntax ~= "scheme") then
			win.file:insert(finish, "\n")
		end
		if eol or at_start or datum then
			local in_form = form_at(pos)
			if first and eol then
				first_invalid = pos
				local level = arg:rep(in_form and 2 or 3) .. " "
				win.file:insert(pos, level)
				pos = pos + #level
			elseif eol or at_start and (not multiline or datum) then
				first_invalid = pos
				local margin = arg
				win.file:insert(pos, margin)
				pos = pos + #margin
			end
			if M.equalprg[win.syntax] and in_form and not (first and eol) and at_start and (not multiline or datum) then
				vis:operator(M.operator.format[vis.modes.NORMAL].id)
				vis:textobject(M.textobject.outer_form[vis.modes.OPERATOR_PENDING].id)
			end
		end
	else
		win.file:insert(pos, arg)
		pos = pos + 1
	end
	selection.pos = pos
	return true
end

local function spacekey(win, arg, selection)
	local pos = selection.pos
	get_sexps(win, pos)
	local next_char = win.file:content(pos, 1)
	local prev_char = pos > 0 and win.file:content(pos - 1, 1)
	local far_char = win.file:content(pos + 1, 1)
	local after_space = prev_char and space:match(prev_char) or not prev_char
	local on_opening_paren = d1:match(next_char)
	local after_opening = prev_char and d1:match(prev_char)
	local before_opening = d1:match(far_char) or ({H.T.outer_string(win, pos + 1)})[1] == pos + 1
	local next_opening = H.M.next_opening(win, pos)
	local op = pWB[next_opening + 1]
	local on_macro = op and op == pos + 1
	local in_macro = op and op < pos + 1
	local before_macro = op and op == pos + 2
	local on_space = next_char == " "
	local dont_double = after_space or on_space and (before_opening or before_macro) or (on_opening_paren or on_macro) and after_space
	local dont_split = on_opening_paren and pWB[pos + 1] or after_opening or in_macro and prev_char ~= "."
	if (dont_double or dont_split) and not escaped(pos, win) then
		local before_closing = D2:match(next_char)
		local before_space = far_char == " "
		if before_closing then
			close(win, ")", selection)
		elseif after_space and on_space and not (before_space or before_opening) then
			win.file:delete(pos, 1)
			selection.pos = pos
		elseif on_space or on_opening_paren then
			selection.pos = pos + 1
		elseif in_macro or on_macro then
			selection.pos = next_opening
		else
			selection.pos = H.M.next_begin(win, pos)
		end
	else
		win.file:insert(pos, arg)
		selection.pos = pos + 1
	end
	first_invalid = pos
	return true
end

local function electrify_any(win, arg, selection)
	local pos = selection.pos
	local next_char = win.file:content(pos, 1)
	local prev_char = pos > 0 and win.file:content(pos - 1, 1)
	local prev2_char = pos > 1 and win.file:content(pos - 2, 1)
	local far_char = win.file:content(pos + 1, 1)
	local after_space = prev_char and space:match(prev_char) or not prev_char
	local on_opening_quote =  ({H.T.outer_string(win, pos)})[1] == pos
	local on_opening_paren = d1:match(next_char)
	local after_opening = prev_char and d1:match(prev_char)
	local behind = pos - PREFIX_MAXLEN > 0 and pos - PREFIX_MAXLEN or 0
	local on_opening = on_opening_paren or on_opening_quote
	local is_macro = l.P{l.Cmt(I * Op^1 * I * l.Cc(pos + 1 - behind), at_pos) + 1 * l.V(1)}:match(win.file:content(behind, pos - behind)..arg)
	local macro_needs_space = is_macro and is_macro > 1 and l.P(1 - d1 - space):match(win.file:content(behind + is_macro - 1, 1))
	local after_digit = prev_char and prev_char:match("%d")
	local after_closing = prev_char and (D2:match(prev_char) or ({H.T.outer_string(win, pos - 1)})[2] == pos)
	local leading = (after_closing or arg ~= "." and prev_char == "." and prev2_char:match("%D") or macro_needs_space or arg == "." and not (after_digit or after_space or after_opening or prev_char == ".")) and " "
	local trailing = not Op:match(arg) and not is_macro and (on_opening or Op:match(next_char)) and " "
	if (trailing or leading) then
		first_invalid = pos
		if not escaped(pos, win) then
			if macro_needs_space then
				win.file:insert(behind + is_macro, leading)
			else
				win.file:insert(pos, (leading and trailing) and leading..trailing or leading or trailing)
			end
			selection.pos = pos + (leading and #leading or 0)
			first_invalid = pos
		end
	else
		if is_macro and next_char == " " and d1:match(far_char) then
			win.file:delete(pos, 1)
			selection.pos = pos
		end
	end
end

local function safe_replace(win, arg, selection)
	local pos = selection.pos
	local next_opening = after(WB, pos)
	if not (pos + 1 == next_opening
		or pWB[next_opening] and pos + 1 >= pWB[next_opening]
		or pos + 1 == after(WE, pos)
		or selection.col - 1 == #win.file.lines[selection.line]) then
		win.file:delete(pos, 1)
		win.file:insert(pos, arg)
	end
	selection.pos = pos + 1
	return true
end

local function backslash(keys)
	if #keys < 1 then vis:info("Character to escape: ") return -1 end
	if #keys == 1 then
		local win = vis.win
		for i = #win.selections, 1, -1 do
			local selection = win.selections[i]
			local pos = selection.pos
			local prefix = "\\"
			-- XXX: currently, the Str lexer token includes characters, too;
			-- matching with Str might recognize existing prefixes other than #\
			if pos == 0 or not escaped(pos, win) and not Str:match(win.file:content(pos - 1, 1)..prefix..keys) then
				prefix = "#" .. prefix
			end
			win.file:insert(pos, prefix..keys)
			selection.pos = pos + #(prefix..keys)
			first_invalid = pos
		end
	end
	return #keys
end

local function wrap_do(action)
	return function()
		local sequence = "<vis-"..action..">"
		if vis.mode == vis.modes.VISUAL then
			sequence = sequence .. "<vis-selections-remove-all>"
		end
		vis:feedkeys(sequence)
		-- force a purge and refill from the very beginning, as undo/redo can create or remove
		-- multiple paragraphs in one go and I don't know how many to rewind before reparsing.
		-- Going some fixed, arbitrary number of paragraphs back instead of to the very beginning
		-- would definitely be faster, but sometimes it will not be enough and will lead to a corrupted cache.
		first_invalid = 0
	end
end

local undo = wrap_do("undo")
local redo = wrap_do("redo")

local function next_whitespace(win, pos)
	local _, start = H.T.outer_sexp(win, pos)
	local finish = start and H.M.next_sexp(win, start)
	if start == finish then return end
	return start, (pWB[finish + 1] and pWB[finish + 1] - 1 or finish)
end

local function prev_whitespace(win, pos)
	local finish = H.T.outer_sexp(win, pos)
	local start = finish and H.M.prev_sexp(win, finish)
	if start == finish then return end
	return start + 1, finish
end

local function transpose()
	if #vis.win.selections < 2 then return end
	local first = vis.win.selections[1]
	local last = vis.win.selections[#vis.win.selections]
	local start, finish = form_at(first.range.finish)
	local on_atom = atom_at(first.pos + 1)
	local opening = not on_atom and start and first.range.finish == start and #vis.win.selections
	local closing = not on_atom and finish and first.pos + 1 == finish and 1
	if opening or closing then
		local form_len = finish - start
		if opening then
			local _, wend = next_whitespace(vis.win, last.range.start)
			if wend and wend < finish then
				vis:feedkeys("<vis-selection-flip>")
				last.pos = wend - 1
			else
				vis.win.file:insert(last.range.start, " ")
			end
		elseif closing then
			local wstart, wend = prev_whitespace(vis.win, last.range.start)
			if wstart and form_len > 1 then
				last.pos = wstart
			else
				vis.win.file:delete(wstart, wend - wstart)
			end
		end
		first_invalid = first.pos
		vis:feedkeys("<vis-selections-rotate-left>")
		vis:feedkeys("<vis-selection-next>")
	else
		start, finish = form_at(last.range.finish)
		on_atom = atom_at(last.pos + 1)
		opening = not on_atom and start and last.range.finish == start and #vis.win.selections
		closing = not on_atom and last.pos + 1 == finish and 1
		if opening or closing then
			local form_len = finish - start
			if opening then
				local wstart, wend = next_whitespace(vis.win, first.range.finish - 1)
				if wend and form_len > 1 then
					vis:feedkeys("<vis-selection-flip>")
					first.pos = wend - 1
				else
					vis.win.file:delete(wstart, wend - wstart)
				end
			elseif closing then
				local wstart = prev_whitespace(vis.win, first.range.finish - 1)
				if wstart and form_len > 1 then
					first.pos = wstart
				else
					vis.win.file:insert(last.range.start, " ")
				end
			end
			first_invalid = first.pos
			vis:feedkeys("<vis-selections-rotate-left>")
		else
			vis:feedkeys("<vis-selections-rotate-left>")
			first_invalid = vis.win.selections[1].pos
			return
		end
	end
	vis:feedkeys("<vis-selections-remove-all>")
	if not M.autoselect
		-- even with autoselect on, if we just barfed/slurped, switch to NORMAL, so it's easy to be repeated:
		or not (atom_at(vis.win.selections[1].range.finish) and atom_at(vis.win.selections[#vis.win.selections].range.finish)) then
		vis.mode = vis.modes.NORMAL
	end
end

local function get_atoms(prefix)
	-- parse the rest of the file, to get more results
	get_sexps(vis.win, vis.win.file.size)
	local ranges = {}
	for i = 1, #wb do
		ranges[i] = {start = wb[i], finish = we[i]}
	end
	local atoms = {}
	for _, r in ipairs(ranges) do
		local a = content:sub(r.start, r.finish)
		if a:match("^"..prefix..".+") then
			atoms[a] = r.start
		end
	end
	return atoms
end

local function choose_atom(prefix)
	local atoms = get_atoms(prefix)
	local args = ""
	for a in pairs(atoms) do
		args = string.format(args.." %q", a)
	end
	if args ~= "" then
		-- XXX: io.popen never returns nil, even when it fails to find the executable...
		-- it just prints an error message; even pcall doesn't help
		local chooser = io.popen("parkour-complete "..args, "r")
		local pick = chooser:read()
		chooser:close()
		return pick
	end
end

local function complete_atom()
	local win = vis.win
	local pos = win.selection.pos
	local bol = pos - win.selection.col + 1
	local prefix = l.P{l.C(atom) * l.Cmt(l.Cc(pos + 1 - bol), at) + 1 * l.V(1)}:match(win.file:content(bol, pos - bol))
	if not prefix then return end
	local a = choose_atom(prefix)
	if a then
		local _, offset = a:find("^"..prefix)
		if offset then
			vis:insert(a:sub(offset + 1))
			first_invalid = win.selections[1].pos - #prefix
		end
	end
end

local function match_word(_)
	vis.mode = vis.modes.VISUAL
	vis:textobject(M.textobject.outer_sexp[vis.modes.VISUAL].id)
end

local function match_next(_, skip)
	local range = vis.win.selection.range
	local cword = content:sub(range.start + 1, range.finish)
	local B, E = (1 - atom - Op), (1 - atom)
	local start, finish = l.P{B * I * cword * I * #E + 1 * l.V(1)}:match(content, range.finish + 1)
	if not (start and finish) then return end
	local single = #vis.win.selections == 1
	if skip then
		vis:feedkeys("<vis-selections-remove-last>")
	end
	if not skip or not single then
		vis:feedkeys("<vis-mark>o<vis-selections-save>")
	end
	vis.mode = vis.modes.NORMAL
	vis.win.selection.pos = start - 1
	vis.mode = vis.modes.VISUAL
	vis.win.selection.pos = finish - 2
	if not skip or not single then
		vis:feedkeys("<vis-mark>o<vis-selections-union><vis-selection-prev>")
	end
end

local match_skip = function() match_next(nil, true) end

local function win_map(name, win, key, action, help)
	if not (key and action) then return end
	for _, mode in pairs(vis.modes) do
		if action[mode] then
			for _, k in pairs(type(key) == "table" and key or {key}) do
				if M.textobject[name] and M.autoselect then
					vis:unmap(vis.modes.VISUAL, k)
				else
					win:map(mode, k, action[mode].binding, help)
				end
			end
		end
	end
end

local function needs_paragraphs(action)
	return ({next_paragraph = true, prev_paragraph = true,
		outer_paragraph = true, inner_paragraph = true})[action]
end

local done_once

local function bail_early()
	if vis.count and vis.count > 1 then
		if done_once then
			done_once = nil
			return true
		else
			done_once = true
		end
	end
	return false
end

local put_combos

-- this function "decorates" motion and textobjects handlers, and takes care of
-- some common things like count argument, incremental parsing, exclusivity, objectwise-ness.
--
-- TODO: make non-nestable objects work with vis.count (maybe use motion-object combos)
local function prep(func, exclusivity)
	return function(win, pos)
		if bail_early() then return pos end
		local start, finish
		local nestable = ({
				[H.M.forward_up] = true,
				[H.M.backward_up] = true,
				[H.T.outer_form] = true,
				[H.T.inner_form] = true,
				})[func]
		if nestable then
			local estart, efinish = escaped(pos, win)
			start, finish = func(win, pos, estart, efinish, exclusivity, vis.count)
			local is_motion = start and not finish
			if not vis.count and vis.mode == vis.modes.VISUAL or is_motion then
				local sel = selection_by_pos(win, pos)
				if not sel then return end
				local old = sel.range
				local same_or_smaller = finish and start >= old.start and finish <= old.finish
				local didnt_move = not finish and start == pos
				if same_or_smaller or didnt_move then
					start, finish = func(win, pos, estart, efinish, exclusivity, 2)
				end
			end
		else
			local forward = ({
				[H.M.next_begin] = true,
				[H.M.next_end] = true,
				[H.M.next_opening] = true,
				[H.M.next_closing] = true,
				[H.M.next_paragraph] = true,
				[H.M.next_section] = true,
				})[func]
			for _ = 1, vis.count or 1 do
				local estart, efinish = escaped(pos, win)
				start, finish = func(win, pos, estart, efinish, exclusivity)
				-- if we have reached the end of the parsed text, parse one paragraph further and retry
				-- until the motion/textobject succeeds, or we reach EOF.
				-- [avalanche-trick]:
				-- Some motions return a second value to signal that they failed to move not because we ran out of cache,
				-- but simply because they have reached a "semantical" limit - it just doesn't make sense for them to move.
				while first_invalid > 0 and first_invalid < win.file.size and (not finish and start and pos == start or finish == first_invalid) do
					get_sexps(win, -1)
					estart, efinish = escaped(pos, win)
					start, finish = func(win, pos, estart, efinish, exclusivity)
				end
				start = (forward and start == pos and first_invalid == win.file.size) and first_invalid or start
				if start and exclusivity then
					start = start + exclusivity
				end
				pos = start or pos
			end
			if start == win.file.size and content:sub(-1) == "\n" then
				start = start - 1
			end
		end
		local is_object = (start and finish and finish ~= true)
		local is_motion = (start and (not finish or finish == true))
		if is_object then
			last_object_type = put_combos[func] and func
		elseif is_motion and (vis.mode == vis.modes.OPERATOR_PENDING or vis.mode == vis.modes.VISUAL) then
			last_object_type = nil
		end
		return start, finish
	end
end

local function prep_map(func, handler)
	if handler == H.M.next_section or handler == H.M.prev_section then
		return function()
			func()
			vis:feedkeys("<vis-window-redraw-top>")
		end
	else
		return func
	end
end

local function new_operator(handler)
	local id = vis:operator_register(handler)
	local binding = id >= 0 and function()
		if vis.mode == vis.modes.VISUAL then
			if handler == H.O.repl_send and M.autoselect or handler == H.O.format then
				vis:textobject(paragraphs_implemented(vis.win) and M.textobject.inner_paragraph[vis.mode].id or VIS_TEXTOBJECT_PARAGRAPH)
			end
		end
		vis:operator(id)
		if vis.mode == vis.modes.OPERATOR_PENDING then
			if ({[H.O.repl_send] = true, [H.O.format] = true})[handler] then
				vis:textobject(paragraphs_implemented(vis.win) and M.textobject.inner_paragraph[vis.mode].id or VIS_TEXTOBJECT_PARAGRAPH)
				vis:motion(paragraphs_implemented(vis.win) and M.motion.next_paragraph[vis.mode].id or VIS_MOVE_PARAGRAPH_NEXT)
			elseif ({[H.O.wrap_round] = true, [H.O.meta_doublequote] = true, [H.O.raise_sexp] = true})[handler] then
				local in_string = H.T.outer_string(vis.win, vis.win.selection.pos)
				if not in_string or handler ~= H.O.raise_sexp then
					vis:textobject(M.textobject.outer_sexp[vis.mode].id)
				else
					vis:textobject(M.textobject.outer_escaped[vis.mode].id)
				end
			elseif ({[H.O.put_after] = true, [H.O.put_before] = true})[handler] then
				if last_object_yanked then
					vis:textobject(put_combos[last_object_yanked])
				else
					vis:motion(VIS_MOVE_NOP)

				end
			end
		elseif (handler == H.O.repl_send) and M.autoselect then
			vis:motion(paragraphs_implemented(vis.win) and M.motion.next_paragraph[vis.mode].id or VIS_MOVE_PARAGRAPH_NEXT)
		end
	end
	local action = {binding = binding, id = id}
	return {
		[vis.modes.NORMAL] = action,
		[vis.modes.VISUAL] = action,
	}
end

local function new_textobject(handler)
	local id = vis:textobject_register(prep(handler))
	local binding = id >= 0 and function()
		vis:textobject(id)
	end
	local action = {binding = binding, id = id}
	return {
		[vis.modes.VISUAL] = action,
		[vis.modes.OPERATOR_PENDING] = action,
	}
end

local function new_motion(handler)
	local exclusivity = ({
		[H.M.prev_end] = 1,
		[H.M.next_end] = 1,
		[H.M.next_closing] = 1,
		[H.M.forward_up] = 1,
	})[handler] or 0

	-- XXX: for motions with no special exclusivity rules this table will "fold" into one element:
	local variants = {[0] = {0}, [exclusivity] = {exclusivity}}
	-- registering separate motions that will be bound to the same key was only necessary because
	-- some motions are inclusive/exclusive depending on the mode, and vis doesn't restore vis.mode when dot-repeating.
	-- I wanted them to keep their exclusivity rules, even when being dot-repeated.
	for i, action in pairs(variants) do
		action.id = vis:motion_register(prep(handler, i))
		action.binding = action.id >= 0 and prep_map(function()
			vis:motion(action.id)
		end, handler)
	end
	return {
		[vis.modes.NORMAL] = variants[0],
		[vis.modes.VISUAL] = variants[0],
		[vis.modes.OPERATOR_PENDING] = variants[exclusivity],
	}
end

local function warn_unbalanced(...)
	local offsets = {}
	for _, list in ipairs({...}) do
		for _, pos in ipairs(list) do
			table.insert(offsets, pos - 1)
		end
	end
	table.sort(offsets)
	vis:info("Psst! You have unbalanced parentheses at offsets: "..table.concat(offsets, ", "))
end

-- in autoselect, clear the current selection, move to the desired object and select it
local function wrap(combo)
	return function()
		local pos = vis.win.selection.pos
		if vis.mode == vis.modes.VISUAL then
			if combo.flip and atom_at(pos + 1) then
				vis:feedkeys("<vis-selection-flip>")
			end
			vis:feedkeys("<vis-selections-remove-all>")
			vis.mode = vis.modes.NORMAL
			local opening = skip_prefix(pos + 1)
			if opening then
				vis.win.selection.pos = opening - 1
			end
		elseif combo[2] ~= VIS_MOVE_NOP then
			local start, finish = form_at(pos + 1)
			if atom_at(pos + 1) or start and finish and (pos + 1 == finish - 1 or pos + 1 == start) then
				vis.mode = vis.modes.VISUAL
				vis:textobject(combo[2][vis.mode].id)
				if not combo.flip then
					vis:feedkeys("<vis-selection-flip>")
				end
				return
			end
		end
		vis:motion(type(combo[1]) == "number" and combo[1] or combo[1][vis.mode].id)
		if combo[2] ~= VIS_MOVE_NOP then vis.mode = vis.modes.VISUAL end
		vis:textobject(type(combo[2]) == "number" and combo[2] or combo[2][vis.mode].id)
		if not combo.flip then
			vis:feedkeys("<vis-selection-flip>")
		end
	end
end

-- in autoselect, keep the current selection, move to the desired object and select it, too
local function wrap_union(combo)
	return function()
		if not combo.flip then
			vis:feedkeys("<vis-selection-flip>")
		end
		if vis.mode == vis.modes.NORMAL and atom_at(vis.win.selection.pos + 1) then
			vis.mode = vis.modes.VISUAL
			vis:textobject(combo[2][vis.mode].id)
		else
			if vis.mode == vis.modes.NORMAL then
				local pos = vis.win.selection.pos
				local start = H.T.inner_form(vis.win, pos)
				if start - 1 == pos then
					vis.mode = vis.modes.VISUAL
					vis.win.selection.pos = (pWB[start] or start) - 1
					vis:feedkeys("<vis-selection-flip>")
				end
			end
			vis:feedkeys("<vis-mark>i<vis-selections-save>")
			vis.mode = vis.modes.NORMAL
			local pos = vis.win.selection.pos
			vis:motion(combo[1][vis.mode].id)
			if pos ~= vis.win.selection.pos then
				vis.mode = vis.modes.VISUAL
				vis:textobject(combo[2][vis.mode].id)
				vis:feedkeys("<vis-mark>i<vis-selections-union>")
			end
		end
		vis:feedkeys("<vis-selection-flip>")
	end
end

-- used for e/ge slurping and barfing - if not on a bracket - move, if on a bracket - create two selections
local function wrap_auto(combo)
	return function()
		local pos = vis.win.selection.pos
		local start, finish = H.T.inner_form(vis.win, pos)
		if start and finish and (start - 1 == pos or finish == pos) then
			vis.mode = vis.modes.VISUAL
			if start - 1 == pos then
				vis.win.selection.pos = (pWB[start] or start) - 1
			end
			wrap_union(combo)()
		else
			vis:motion(combo[3][vis.mode].id)
		end
	end
end

local function iprep(func, win)
	return function()
		insert = true
		func(win)
		insert = nil
	end
end

local function init(win)
	local L = vis.lexers
	local rules = L.lexers[win.syntax]._RULES
	C = rules[L.COMMENT] / 0
	Str = rules[L.STRING] / 0
	Op = rules[L.OPERATOR] / 0
	local Num = rules[L.NUMBER] / 0
	local Kw = rules[L.KEYWORD] / 0
	local Id = rules[L.IDENTIFIER] / 0
	local opening, closing = {}, {}
	for o, c in pairs(opposite) do
		if o < c then
			table.insert(opening, o)
			table.insert(closing, c)
		end
	end
	d1, d2 = l.Cg(l.S(table.concat(opening)), "d"), l.Cmt(l.Cb("d") * l.C(1), function(_, _, o, c) return opposite[o] == c end)
	D2 = l.S(table.concat(closing))
	a_lisp = ({scheme = true, lisp = true, clojure = true})[win.syntax]
	-- XXX: shebangs; the "shebang block" is for Guile
	C = C + l.P("#!" * (l.P(1) - "#!" - "!#")^0 * "!#") + "#!" * L.nonnewline^0 * 1
	if a_lisp then
		vis:command("set expandtab on")
		vis:command("set tabwidth "..tabwidth)
		-- XXX: keep only reader macro prefixes in Op:
		Op = Op - l.S".()"
		Id = Op^0 * Id
		M.comment = ";"
		-- XXX: fix line comments to include EOL; otherwise, in insert mode, EOL is
		-- considered code - C-w deletes the whole comment, autopairs get inserted, etc.
		C = ";" * L.nonnewline^0 * 1 + C
		if win.syntax == "lisp" then
			local Ent = rules["entity"] / 0
			atom = Kw + Id + Num + Ent
			d1, d2 = l.P"(", l.P(opposite["("])
			D2 = d2
		elseif win.syntax == "scheme" then
			-- XXX: if the lexer gets better, someday, these work-arounds will "self-destruct"
			-- XXX: order matters! more specific patterns should be near the start of Op
			if not (Op:match("#42") == #"#42" + 1) then
				Op = l.P("#" * L.dec_num) + Op
			end
			if not (Op:match("#42vu8") == #"#42vu8" + 1) then
				Op = l.P("#" * L.dec_num^-1 * "vu8") + Op
			end
			if not (Op:match("#s16") == #"#s16" + 1) then
				-- FIXME: the floats somehow interfere with the boolean #f and disbalance the parser:
				Op = l.P("#" * (l.S"us" * ("8" + "16" + "32" + "64") --[[+ l.P"f" * ("32" + "64")]])) + Op
			end
			local Sym = rules["symbol"] / 0
			local Bool = rules["boolean"] / 0
			atom = Bool + Num + Kw + Id + Sym
		elseif win.syntax == "clojure" then
			local Func = rules["func"] / 0
			atom = Kw + Func + Id + Num
		end
		atom = atom + "..." + "."
	elseif win.syntax == "lua" then
		C = "--" * L.nonnewline^0 * 1 + C
		-- TODO: this is not enough, paragraphs should be properly defined too:
		Op = Op - l.S"(){}[]"
		atom = Kw + Id + Num + Op^1
	elseif win.syntax == "ansi_c" then
		C = "//" * L.nonnewline_esc^0 * 1 + C
		-- TODO: this is not enough, paragraphs should be properly defined too:
		Op = Op - l.S"(){}[]"
		atom = Kw + Id + Num + Op^1
	else
		atom = Kw + Id + Num
	end
	word = Num + Id
	for name, mapping in pairs(M.map) do
		if (paragraphs_implemented(win) or not needs_paragraphs(name))
			and not (name == "format" and not M.equalprg[win.syntax] or name == "repl_send" and not M.repl_fifo) then
			win_map(name, win, mapping, M.motion[name] or M.textobject[name] or M.operator[name])
		end
	end
	for name, mapping in pairs(M.insert) do
		win:map(vis.modes.INSERT, mapping, iprep(H.I[name], win))
	end
	win:map(vis.modes.INSERT, "\\", backslash)
	win:map(vis.modes.INSERT, "<Enter>", newline)
	win:map(vis.modes.NORMAL, "u", undo)
	win:map(vis.modes.NORMAL, "<C-r>", redo)
	win:map(vis.modes.NORMAL, "x", "dl")
	win:map(vis.modes.NORMAL, "dd", "dal")
	win:map(vis.modes.NORMAL, "cc", "cil")
	win:map(vis.modes.NORMAL, "yy", "yal")
	win:map(vis.modes.VISUAL, "-", transpose)
	vis:unmap(vis.modes.NORMAL, "-")
	win:map(vis.modes.INSERT, "<C-n>", complete_atom)
	win:map(vis.modes.NORMAL, "<C-n>", match_word)
	win:map(vis.modes.VISUAL, "<C-n>", match_next)
	win:map(vis.modes.VISUAL, "<C-x>", match_skip)
	win:map(vis.modes.OPERATOR_PENDING, "%", function()
		if vis.count then
			vis:motion(VIS_MOVE_PERCENT)
		else
			vis:textobject(M.textobject.match_pair_inclusive[vis.modes.OPERATOR_PENDING].id)
		end
	end)
	win:map(vis.modes.NORMAL, "%", function()
		vis:motion(vis.count and VIS_MOVE_PERCENT or M.motion.match_pair[vis.modes.NORMAL].id)
	end)
	win:map(vis.modes.VISUAL, "%", function()
		vis:motion(vis.count and VIS_MOVE_PERCENT or M.motion.match_pair[vis.modes.VISUAL].id)
	end)
	-- XXX: redefine J so it triggers a reparse
	win:map(vis.modes.NORMAL, "J", function()
		vis:feedkeys("<vis-join-lines>")
		first_invalid = win.selection.pos
	end)
	-- XXX: redefine o and O because the built-in ones contain hardcoded calls to <Enter> and trigger repl_send
	win:map(vis.modes.NORMAL, "o", function()
		vis:motion(VIS_MOVE_LINE_END)
		vis.mode = vis.modes.INSERT
		newline(nil, true)
	end)
	win:map(vis.modes.NORMAL, "O", function()
		local first_line =  vis.win.selection.line == 1
		if not first_line then
			vis:motion(VIS_MOVE_LINE_UP)
			vis:motion(VIS_MOVE_LINE_END)
		else
			vis:motion(VIS_MOVE_LINE_BEGIN)
		end
		vis.mode = vis.modes.INSERT
		newline(nil, true)
		if first_line then
			vis:motion(VIS_MOVE_LINE_UP)
		end
	end)
	local extend_combos = {
		[M.map.next_end] = {M.motion.next_sexp, M.textobject.outer_sexp, --[[non-autoselect]] M.motion.next_end},
		[M.map.prev_end] = {M.motion.prev_sexp, M.textobject.outer_sexp, --[[non-autoselect]] M.motion.prev_end, flip = true},
	}
	if M.autoselect then
		win:unmap(vis.modes.VISUAL, "i")
		win:unmap(vis.modes.VISUAL, "a")
		-- make sure there are no mappings that start with i or a, otherwise switching from visual straight to insert mode won't work:
		local bindings = vis:mappings(vis.modes.VISUAL)
		for key in pairs(bindings) do
			if key:sub(1, 1):match("[ia]") then
				vis:unmap(vis.modes.VISUAL, key)
			end
		end
		vis:map(vis.modes.VISUAL, "i", function() vis.mode = vis.modes.INSERT end)
		vis:map(vis.modes.VISUAL, "a", function() if atom_at(vis.win.selection.pos + 1) then vis:feedkeys("<vis-selection-flip>") end vis:motion(VIS_MOVE_CHAR_NEXT) vis.mode = vis.modes.INSERT end)
		win:map(vis.modes.VISUAL, "u", undo)
		win:map(vis.modes.VISUAL, "<C-r>", redo)
		local move_combos = {
			[M.map.next_begin] = {M.motion.next_begin, M.textobject.outer_sexp},
			[M.map.prev_begin] = {M.motion.prev_begin, M.textobject.outer_sexp},
			[M.map.next_opening] = {M.motion.next_opening, M.textobject.outer_form},
			[M.map.prev_closing] = {M.motion.prev_closing, M.textobject.outer_form, flip = true},
			[M.map.next_closing] = {M.motion.next_closing, M.textobject.outer_form, flip = true},
			[M.map.prev_opening] = {M.motion.prev_opening, M.textobject.outer_form},
			[M.map.forward_up] = {M.motion.forward_up, M.textobject.outer_form, flip = true},
			[M.map.backward_up] = {M.motion.backward_up, M.textobject.outer_form},
			[M.map.forward_down] = {M.motion.forward_down, M.textobject.outer_form},
			[M.map.backward_down] = {M.motion.backward_down, M.textobject.outer_form, flip = true},
			[M.map.next_paragraph] = paragraphs_implemented(win) and {M.motion.next_paragraph, M.textobject.outer_paragraph} or {VIS_MOVE_PARAGRAPH_NEXT, VIS_TEXTOBJECT_PARAGRAPH_OUTER},
			[M.map.prev_paragraph] = paragraphs_implemented(win) and {M.motion.prev_paragraph, M.textobject.outer_paragraph} or {VIS_MOVE_PARAGRAPH_PREV, VIS_TEXTOBJECT_PARAGRAPH_OUTER},
			[M.map.next_section] = {M.motion.next_section, VIS_MOVE_NOP},
			[M.map.prev_section] = {M.motion.prev_section, VIS_MOVE_NOP},
			[M.map.search_word_forward] = {M.motion.search_word_forward, VIS_MOVE_NOP},
			[M.map.search_word_backward] = {M.motion.search_word_backward, VIS_MOVE_NOP},
			j = {VIS_MOVE_LINE_DOWN, VIS_MOVE_NOP}, k = {VIS_MOVE_LINE_UP, VIS_MOVE_NOP},
			h = {VIS_MOVE_CHAR_PREV, VIS_MOVE_NOP}, l = {VIS_MOVE_CHAR_NEXT, VIS_MOVE_NOP},
			gg = {VIS_MOVE_FILE_BEGIN, VIS_MOVE_NOP}, G = {VIS_MOVE_FILE_END, VIS_MOVE_NOP},
			H = {VIS_MOVE_WINDOW_LINE_TOP, VIS_MOVE_NOP}, M = {VIS_MOVE_WINDOW_LINE_MIDDLE, VIS_MOVE_NOP}, L = {VIS_MOVE_WINDOW_LINE_BOTTOM, VIS_MOVE_NOP},
		}
		for key, combo in pairs(move_combos) do
			win:map(vis.modes.NORMAL, key, wrap(combo))
			win:map(vis.modes.VISUAL, key, wrap(combo))
		end
		for key, combo in pairs(extend_combos) do
			win:map(vis.modes.NORMAL, key, wrap_union(combo))
			win:map(vis.modes.VISUAL, key, wrap_union(combo))
		end
		win:map(vis.modes.VISUAL, "/", "<vis-mode-normal>/")
		win:map(vis.modes.VISUAL, "?", "<vis-mode-normal>?")
	else
		for key, combo in pairs(extend_combos) do
			win:map(vis.modes.NORMAL, key, wrap_auto(combo))
		end
	end
	put_combos = {
		[H.T.outer_sexp] = M.textobject.outer_sexp[vis.modes.OPERATOR_PENDING].id,
		[H.T.outer_form] = M.textobject.outer_sexp[vis.modes.OPERATOR_PENDING].id,
		[H.T.outer_string] = M.textobject.outer_sexp[vis.modes.OPERATOR_PENDING].id,
		[H.T.outer_paragraph] = paragraphs_implemented(win) and M.textobject.outer_paragraph[vis.modes.OPERATOR_PENDING].id or VIS_TEXTOBJECT_PARAGRAPH_OUTER,
		[H.T.inner_paragraph] = paragraphs_implemented(win) and M.textobject.outer_paragraph[vis.modes.OPERATOR_PENDING].id or VIS_TEXTOBJECT_PARAGRAPH_OUTER,
		[H.T.outer_line] = VIS_TEXTOBJECT_OUTER_LINE,
		[H.T.inner_line] = VIS_TEXTOBJECT_OUTER_LINE,
		[H.M.match_pair] = M.textobject.outer_sexp[vis.modes.OPERATOR_PENDING].id,
		[H.T.match_pair_inclusive] = M.textobject.outer_sexp[vis.modes.OPERATOR_PENDING].id,
	}
end

local last_mode, last_win, last_syntax

vis.events.subscribe(vis.events.WIN_STATUS, function(win)
	if M.syntax[win.syntax] and win == vis.win then
		local pos = win.selection.pos
		if win.syntax ~= last_syntax then
			if not d1 then
				init(win)
			end
			last_syntax = win.syntax
		end
		if vis.mode ~= last_mode then
			if vis.mode == vis.modes.NORMAL and sexps then
				get_sexps(win, pos)
				if last_mode == vis.modes.INSERT then
					if M.equalprg[win.syntax] and a_lisp then
						-- XXX: using vis:operator/vis:textobject would sometimes cause flickering even when no formatting happened
						-- If we call the handlers directly it only flickers when the formatting actually changed the file
						local start, finish = H.T.outer_form(win, pos)
						if start and pos == start then
							-- if the cursor was exactly on an opening bracket, the above call would return its bounds,
							-- but we are interested in the *current* form, which is its parent
							start, finish = H.T.outer_form(win, pos, nil, nil, nil, 2)
						end
						local newpos = H.O.format(win.file, {start = start, finish = finish}, pos)
						if newpos ~= win.selection.pos then  -- only if any reformatting actually happened
							win.selection.pos = pos
						end
					end
				elseif last_mode == vis.modes.VISUAL then
					last_object_type = nil
				end
			end
			last_mode = vis.mode
		end
		if win ~= last_win then
			last_win = win
			first_invalid = nil
			get_sexps(win, pos)
			a_lisp = ({scheme = true, lisp = true, clojure = true})[win.syntax]
		-- if we have jumped beyond the end of the parsed text, parse till the new position
		elseif vis.mode ~= vis.modes.INSERT then
			if first_invalid and (pos >= first_invalid) then
				if last_repaired then
					if last_repaired > pos then
						pos = last_repaired
					end
					last_repaired = nil
				end
				get_sexps(win, pos)
			end
			local prev_section = H.M.prev_section(win, pos + 1)
			if prev_section > win.viewport.start and pos > win.viewport.start then
				win.selection.pos = prev_section
				vis:feedkeys("<vis-window-redraw-top>")
				win.selection.pos = pos
				vis:feedkeys("<vis-redraw>")
			end
		end
		if unbalanced and vis.mode == vis.modes.NORMAL then
			warn_unbalanced(ub, ue)
		end
	end
end)

vis.events.subscribe(vis.events.INPUT, function(char)
	if M.syntax[vis.win.syntax] then
		local handler =
			d1:match(char) and brackets
			or D2:match(char) and close
			or char == " " and spacekey
			or char == '"' and doublequote
			or char == M.comment and comment
		local ret
		local win = vis.win
		for i = #win.selections, 1, -1 do
			ret = (vis.mode == vis.modes.REPLACE and safe_replace or handler or electrify_any)(win, char, win.selections[i])
		end
		return ret
	end
end)

-- flush any code stuck in the fifo, so starting a REPL after the file has been closed won't read old stuff in.
vis.events.subscribe(vis.events.WIN_CLOSE, function(_)
	if repl_fifo then
		repl_fifo:close()
		repl_fifo = io.open(M.repl_fifo, "w+")
		repl_fifo:close()
		repl_fifo = nil
	end
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	if M.syntax[win.syntax] then
		init(win)
	end
end)

vis.events.subscribe(vis.events.INIT, function()
	for name, handler in pairs(H.M) do
		M.motion[name] = new_motion(handler)
	end
	for name, handler in pairs(H.T) do
		M.textobject[name] = new_textobject(handler)
	end
	for name, handler in pairs(H.O) do
		M.operator[name] = new_operator(handler)
	end
end)

return M
