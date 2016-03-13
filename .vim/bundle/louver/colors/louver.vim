" Name:			louver.vim
" Maintainer:	Kojo Sugita
" Last Change:  2008-08-15
" Version:		1.0

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = 'louver'

if (&term == "xterm") || (&term == "linux")
	set t_Co=16
elseif &term == "vt320"
	set t_Co=8
endif

" Normal
hi Normal		guifg=black			guibg=none gui=none
hi Normal		ctermfg=black		ctermbg=none cterm=none
hi NonText		guifg=darkgray		guibg=none gui=none
hi NonText		ctermfg=darkgray	ctermbg=lightgray	cterm=none
hi SpecialKey	guifg=darkgray		guibg=white			gui=none
hi SpecialKey	ctermfg=darkgray	ctermbg=white		cterm=none

hi Cursor		guifg=white			guibg=black			gui=none
hi Cursor		ctermfg=white		ctermbg=black		cterm=none
hi lCursor		guifg=white			guibg=black			gui=none
hi lCursor		ctermfg=white		ctermbg=black		cterm=none
hi CursorIM		guifg=white			guibg=black			gui=none
hi CursorIM		ctermfg=white		ctermbg=black		cterm=none

" Search
hi Search		guifg=black			guibg=lightred		gui=none
hi Search		ctermfg=black		ctermbg=lightred	cterm=none
hi IncSearch	guifg=black			guibg=lightred		gui=none
hi IncSearch	ctermfg=black		ctermbg=lightred	cterm=none

" Matches
hi MatchParen	guifg=black			guibg=darkgray		gui=none
hi MatchParen	ctermfg=black		ctermbg=darkgray	cterm=none

" status line
hi StatusLine	guifg=white			guibg=darkgray		gui=bold
hi StatusLine	ctermfg=white		ctermbg=darkgray	cterm=bold
hi StatusLineNC	guifg=gray			guibg=darkgray		gui=bold
hi StatusLineNC	ctermfg=gray		ctermbg=darkgray	cterm=bold

" Diff
hi DiffAdd		guifg=darkmagenta	guibg=white			gui=none
hi DiffAdd		ctermfg=darkmagenta	ctermbg=white		cterm=none
hi DiffChange	guifg=darkmagenta	guibg=white			gui=none
hi DiffChange	ctermfg=darkmagenta	ctermbg=white		cterm=none
hi DiffDelete	guifg=white			guibg=black			gui=none
hi DiffDelete	ctermfg=white		ctermbg=black		cterm=none
hi DiffText		guifg=darkmagenta	guibg=white			gui=bold
hi DiffText		ctermfg=darkmagenta	ctermbg=white		cterm=bold

" Folds
hi Folded		guifg=black			guibg=gray			gui=none
hi Folded		ctermfg=black		ctermbg=gray		cterm=none
hi FoldColumn	guifg=black			guibg=gray			gui=none
hi FoldColumn	ctermfg=black		ctermbg=gray		cterm=none

" Syntax
hi Number		ctermfg=blue		ctermbg=none cterm=none
hi Char			ctermfg=blue		ctermbg=none cterm=none
hi String		ctermfg=blue		ctermbg=none cterm=none
hi Boolean		ctermfg=blue		ctermbg=none cterm=none
hi Constant		ctermfg=darkred		ctermbg=none cterm=none

hi Statement	ctermfg=darkred		ctermbg=none cterm=bold
hi Comment		ctermfg=darkgreen	ctermbg=none cterm=none
hi Identifier	ctermfg=darkblue ctermbg=none cterm=none
hi Function		ctermfg=darkmagenta	ctermbg=none cterm=bold

"In Markdown the ==== of headingsk
hi PreProc		ctermfg=gray ctermbg=none cterm=bold 
hi Type			ctermfg=darkblue	ctermbg=none cterm=bold

"\n, \0, %d, %s, etc...
hi Special		ctermfg=darkred		ctermbg=none cterm=none

" Tree
hi Directory	ctermfg=darkmagenta	ctermbg=white		cterm=bold

" Message
"hi ModeMsg		ctermfg=black		ctermbg=none cterm=none
"hi MoreMsg		ctermfg=black		ctermbg=none cterm=none
"hi WarningMsg	ctermfg=red			ctermbg=none cterm=none
"hi ErrorMsg		ctermfg=white		ctermbg=none cterm=none
"hi Question		ctermfg=black		ctermbg=none cterm=none

hi VertSplit	ctermfg=black		ctermbg=black		cterm=none
hi LineNr		ctermfg=black		ctermbg=lightgray	cterm=none
hi Title		ctermfg=blue ctermbg=none cterm=bold
hi Visual		ctermfg=white		ctermbg=lightyellow cterm=none
hi VisualNOS	ctermfg=white		ctermbg=black		cterm=none
hi WildMenu		ctermfg=white		ctermbg=black		cterm=none

"Define, def
hi Underlined	ctermfg=darkmagenta	ctermbg=white		cterm=underline
hi Error		ctermfg=red			ctermbg=white		cterm=none
hi Todo			ctermfg=black		ctermbg=white		cterm=none
hi SignColumn	ctermfg=black		ctermbg=white		cterm=none

if version >= 700
  "Pmenu
  hi Pmenu							ctermbg=gray
  hi PmenuSel	ctermfg=white		ctermbg=black
  hi PmenuSbar						ctermbg=gray

  "Tab
  hi TabLine		ctermfg=gray	ctermbg=darkgray	cterm=none
  hi TabLineFill	ctermfg=gray	ctermbg=gray		cterm=none
  hi TabLineSel		ctermfg=white	ctermbg=black		cterm=none
endif

finish

" vim: set foldmethod=marker: set fenc=utf-8:
