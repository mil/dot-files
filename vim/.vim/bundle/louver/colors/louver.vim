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
hi Normal		guifg=black			guibg=NONE gui=NONE
hi Normal		ctermfg=black		ctermbg=NONE cterm=NONE
hi NonText		guifg=darkgray		guibg=NONE gui=NONE
hi NonText		ctermfg=darkgray	ctermbg=lightgray	cterm=NONE
hi SpecialKey	guifg=darkgray		guibg=white			gui=NONE
hi SpecialKey	ctermfg=darkgray	ctermbg=white		cterm=NONE

hi Cursor		guifg=white			guibg=black			gui=NONE
hi Cursor		ctermfg=white		ctermbg=black		cterm=NONE
hi lCursor		guifg=white			guibg=black			gui=NONE
hi lCursor		ctermfg=white		ctermbg=black		cterm=NONE
hi CursorIM		guifg=white			guibg=black			gui=NONE
hi CursorIM		ctermfg=white		ctermbg=black		cterm=NONE

" Search
hi Search		guifg=black			guibg=lightred		gui=NONE
hi Search		ctermfg=black		ctermbg=lightred	cterm=NONE
hi IncSearch	guifg=black			guibg=lightred		gui=NONE
hi IncSearch	ctermfg=black		ctermbg=lightred	cterm=NONE

" Matches
hi MatchParen	guifg=black			guibg=darkgray		gui=NONE
hi MatchParen	ctermfg=black		ctermbg=darkgray	cterm=NONE

" status line
hi StatusLine	guifg=white			guibg=darkgray		gui=bold
hi StatusLine	ctermfg=white		ctermbg=darkgray	cterm=bold
hi StatusLineNC	guifg=gray			guibg=darkgray		gui=bold
hi StatusLineNC	ctermfg=gray		ctermbg=darkgray	cterm=bold

" Diff
hi DiffAdd		guifg=darkmagenta	guibg=white			gui=NONE
hi DiffAdd		ctermfg=darkmagenta	ctermbg=white		cterm=NONE
hi DiffChange	guifg=darkmagenta	guibg=white			gui=NONE
hi DiffChange	ctermfg=darkmagenta	ctermbg=white		cterm=NONE
hi DiffDelete	guifg=white			guibg=black			gui=NONE
hi DiffDelete	ctermfg=white		ctermbg=black		cterm=NONE
hi DiffText		guifg=darkmagenta	guibg=white			gui=bold
hi DiffText		ctermfg=darkmagenta	ctermbg=white		cterm=bold

" Folds
hi Folded		guifg=black			guibg=gray			gui=NONE
hi Folded		ctermfg=black		ctermbg=gray		cterm=NONE
hi FoldColumn	guifg=black			guibg=gray			gui=NONE
hi FoldColumn	ctermfg=black		ctermbg=gray		cterm=NONE

" Syntax
hi Number		ctermfg=blue		ctermbg=NONE cterm=NONE
hi Char			ctermfg=blue		ctermbg=NONE cterm=NONE
hi String		ctermfg=blue		ctermbg=NONE cterm=NONE
hi Boolean		ctermfg=blue		ctermbg=NONE cterm=NONE
hi Constant		ctermfg=darkred		ctermbg=NONE cterm=NONE

hi Statement	ctermfg=darkred		ctermbg=NONE cterm=bold
hi Comment		ctermfg=darkgreen	ctermbg=NONE cterm=NONE
hi Identifier	ctermfg=darkblue ctermbg=NONE cterm=NONE
hi Function		ctermfg=darkmagenta	ctermbg=NONE cterm=bold

"In Markdown the ==== of headingsk
hi PreProc		ctermfg=gray ctermbg=NONE cterm=bold 
hi Type			ctermfg=darkblue	ctermbg=NONE cterm=bold

"\n, \0, %d, %s, etc...
hi Special		ctermfg=darkred		ctermbg=NONE cterm=NONE

" Tree
hi Directory	ctermfg=darkmagenta	ctermbg=white		cterm=bold

" Message
"hi ModeMsg		ctermfg=black		ctermbg=NONE cterm=NONE
"hi MoreMsg		ctermfg=black		ctermbg=NONE cterm=NONE
"hi WarningMsg	ctermfg=red			ctermbg=NONE cterm=NONE
"hi ErrorMsg		ctermfg=white		ctermbg=NONE cterm=NONE
"hi Question		ctermfg=black		ctermbg=NONE cterm=NONE

hi VertSplit	ctermfg=black		ctermbg=black		cterm=NONE
hi LineNr		ctermfg=black		ctermbg=lightgray	cterm=NONE
hi Title		ctermfg=blue ctermbg=NONE cterm=bold
hi Visual		ctermfg=white		ctermbg=yellow cterm=NONE
hi VisualNOS	ctermfg=white		ctermbg=black		cterm=NONE
hi WildMenu		ctermfg=white		ctermbg=black		cterm=NONE

"Define, def
hi Underlined	ctermfg=darkmagenta	ctermbg=white		cterm=underline
hi Error		ctermfg=red			ctermbg=white		cterm=NONE
hi Todo			ctermfg=black		ctermbg=white		cterm=NONE
hi SignColumn	ctermfg=black		ctermbg=white		cterm=NONE

if version >= 700
  "Pmenu
  hi Pmenu							ctermbg=gray
  hi PmenuSel	ctermfg=white		ctermbg=black
  hi PmenuSbar						ctermbg=gray

  "Tab
  hi TabLine		ctermfg=gray	ctermbg=darkgray	cterm=NONE
  hi TabLineFill	ctermfg=gray	ctermbg=gray		cterm=NONE
  hi TabLineSel		ctermfg=white	ctermbg=black		cterm=NONE
endif

finish

" vim: set foldmethod=marker: set fenc=utf-8:
