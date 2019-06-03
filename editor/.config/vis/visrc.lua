require('vis')
local current_file = "nofile"

--local pk = require("parkour")
--
--pk.equalprg.scheme = "scmindent"
--pk.equalprg.lisp = "yasi --dialect lisp"
--pk.equalprg.clojure = "yasi --dialect clojure"
--pk.repl_fifo = "/home/m/.repl_fifo"
--pk.autoselect = true

--pk.syntax.lua = true       -- non-Lisps kind of work, but haven't been tested much



function file_exists(name)
  local f=io.open(name,"r")
  if f~=nil then io.close(f) return true else return false end
end

function set_title()
  local f_name = current_file.name
  local abs_path = current_file.path
  local title = f_name .. " (" .. abs_path .. ")"
  vis:command("!xdotool getactivewindow set_window --name '" .. title .. "'")
end

function load_extras()
  local extras = "/home/mil/.config/vis_additional/visrc.lua"
  if file_exists(extras) then 
    dofile(extras)
  end
end

function file_type_exec(file)
  if not file then return end

  if string.match(file, ".ebuild") then 
    vis:command('set syntax bash')
  --elseif string.match(file, ".ts") then
  --  vis:command('set syntax javascript')
  elseif string.match(file, ".ts") then
    vis:command('set syntax typescript')
  elseif string.match(file, ".boot") then 
    vis:command('set syntax clj')
  elseif string.match(file, "COMMIT_EDITMSG") then 
    vis:command('set syntax diff')
  elseif string.match(file, ".rej") then 
    vis:command('set syntax diff')
  elseif string.match(file, ".commit.hg") then
    vis:command('set syntax diff')
  elseif string.match(file, "Makefile") then 
    vis:command('set expandtab off')
  elseif string.match(file, ".go") then 
    vis:command('set expandtab off')
    vis:command('set show-tabs off')
  elseif string.match(file, ".mod") then
    vis:command('set expandtab off')
  elseif string.match(file, ".sum") then
    vis:command('set expandtab off')
  elseif string.match(file, ".java") then
    vis:command('set tabwidth 4')
  elseif string.match(file, ".rs") then
    vis:command('set tabwidth 4')
  elseif string.match(file, ".py") then
    vis:command('set tabwidth 4')
  elseif string.match(file, ".rb") then
    vis:command('set tabwidth 2')
  elseif string.match(file, ".scss") then
    vis:command('set tabwidth 2')
  elseif string.match(file, ".cljs") then
    vis:command('set syntax clj')
  elseif string.match(file, ".clj") then
    vis:command('set syntax clj')
  end
end

function cb_win_open()
  vis:command('set number')
  vis:command('set colorcolumn 80')
  vis:command('set tabwidth 2')
  vis:command('set cursorline')
  vis:command('set autoindent on')
  vis:command('set shell /bin/sh')
  --vis:command('set th d')
  vis:command('set th l')

  vis:command('set expandtab on')
  vis:command('set show-tabs on')
  vis:command('set show-eof on')
  vis:command('set savemethod inplace')
  vis:command('set show-newlines off')

  --#File.lines
  if current_file and #current_file.lines > 1000 and (
    -- non-performant lpegs
    string.match(current_file.path, ".yml")
  ) then
    vis:command('set syntax off')
  end

  if current_file and current_file.path ~= nil then
    file_type_exec(current_file.name)
  end

  --vis:command('set show-spaces on')
  pcall(set_title)
end

function cb_file_open(file)
  current_file  = file
  if file == nil or file.path == nil then return end
  file_type_exec(file.path)
end

function cb_file_save_post(file, path)
  forks = {}
  forks[".java"]  = { }
  forks[".sc"]  = { 
    "oscsend localhost 57120 /reloadFile s " .. path
  }  

  local extension = path:match("^.+(%..+)$")
  if (forks[extension] ~= nil) then for cmdI = 1, #forks[extension] do
      local fork_command = forks[extension][cmdI]
      vis:feedkeys(":!" .. fork_command .. "<Enter><Escape>")
  end end

  return true
end

vis.events.subscribe(vis.events.INIT, function()
  vis.events.subscribe(vis.events.WIN_OPEN, cb_win_open)
  vis.events.subscribe(vis.events.FILE_OPEN, cb_file_open)
  vis.events.subscribe(vis.events.FILE_SAVE_POST, cb_file_save_post)
  load_extras()
end)
