" local syntax file - set colors on a per-machine basis:
" vim: tw=0 ts=4 sw=4
" Vim color file
" Maintainer:	Dr. J. Pfefferl <johann.pfefferl@agfa.com>
" Source:	$Source: /MISC/projects/cvsroot/user/pfefferl/vim/colors/nuvola.vim,v $
" Id:	$Id: nuvola.vim,v 1.8 2003/07/22 09:00:16 pfefferl Exp $
" Last Change:	$Date: 2003/07/22 09:00:16 $

set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "nuvola"

hi Normal ctermfg=black ctermbg=NONE guifg=black guibg=#FAFAFA

" Search 
hi IncSearch cterm=UNDERLINE ctermfg=Black ctermbg=brown gui=UNDERLINE guifg=Black guibg=#FFE568
hi Search term=reverse cterm=UNDERLINE ctermfg=Black ctermbg=brown gui=NONE guifg=Black guibg=#FFE568

" Messages 
hi ErrorMsg gui=BOLD guifg=#EB1513 guibg=NONE
hi! link WarningMsg ErrorMsg
hi ModeMsg gui=BOLD guifg=#0070ff guibg=NONE
hi! link MoreMsg Comment
hi! link Question Comment

" Split area 
"hi StatusLine term=BOLD,reverse cterm=NONE ctermfg=Yellow ctermbg=DarkGray gui=BOLD guibg=#75B3F1 guifg=white
"hi StatusLineNC gui=NONE guibg=#75B3F1 guifg=#E9E9F4
hi StatusLine term=BOLD,reverse cterm=NONE ctermfg=Yellow ctermbg=DarkGray gui=BOLD guibg=#4292E6 guifg=white
hi StatusLineNC gui=NONE guibg=#4292E6 guifg=#E9E9F4
hi! link VertSplit StatusLineNC
hi WildMenu gui=UNDERLINE guifg=#428EDE guibg=#E9E9F4

" Diff 
hi DiffText   gui=NONE guifg=#f83010 guibg=#ffeae0
hi DiffChange gui=NONE guifg=#006800 guibg=#d0ffd0
hi DiffDelete gui=NONE guifg=#2020ff guibg=#c8f2ea
hi! link DiffAdd DiffDelete

" Cursor 
hi Cursor       gui=NONE guifg=white guibg=blue
"hi lCursor      gui=NONE guifg=#f8f8f8 guibg=#8000ff
hi CursorIM     gui=NONE guifg=#f8f8f8 guibg=#8000ff

" Fold 
hi Folded gui=NONE guibg=#B5EEB5 guifg=black
"hi FoldColumn gui=NONE guibg=#9FD29F guifg=black
hi! link FoldColumn Folded

" Other 
hi Directory    gui=NONE guifg=#0000ff guibg=NONE
hi LineNr       gui=NONE guifg=#8080a0 guibg=NONE
hi NonText      gui=BOLD guifg=#4000ff guibg=#ececf0
"hi SpecialKey   gui=NONE guifg=#A35B00 guibg=NONE
hi Title        gui=NONE guifg=black guibg=#9CCEFF
hi Visual term=reverse ctermfg=yellow ctermbg=black gui=NONE guifg=Black guibg=#D2E8FF
hi VisualNOS term=reverse ctermfg=yellow ctermbg=black gui=REVERSE guifg=Black guibg=#FFE568

" Syntax group 
hi Comment term=BOLD ctermfg=darkgray guifg=#515C6A
hi Constant term=UNDERLINE ctermfg=red guifg=red2
hi Error term=REVERSE ctermfg=15 ctermbg=9 guibg=Red guifg=White
hi Identifier term=UNDERLINE ctermfg=Blue guifg=Blue
hi Number   term=UNDERLINE ctermfg=red guifg=green3
hi PreProc term=UNDERLINE ctermfg=darkblue guifg=#1677D5
hi Special term=BOLD ctermfg=darkmagenta guifg=red3
hi Statement term=BOLD ctermfg=DarkRed gui=NONE guifg=orange3
hi Tag term=BOLD ctermfg=DarkGreen guifg=DarkGreen
hi Todo term=STANDOUT ctermbg=Yellow ctermfg=blue guifg=Blue guibg=Yellow
hi Type term=UNDERLINE ctermfg=Blue gui=NONE guifg=Blue
hi! link String	Constant
hi! link Character	Constant
hi! link Boolean	Constant
hi! link Float		Number
hi! link Function	Identifier
hi! link Conditional	Statement
hi! link Repeat	Statement
hi! link Label		Statement
hi! link Operator	Statement
hi! link Keyword	Statement
hi! link Exception	Statement
hi! link Include	PreProc
hi! link Define	PreProc
hi! link Macro		PreProc
hi! link PreCondit	PreProc
hi! link StorageClass	Type
hi! link Structure	Type
hi! link Typedef	Type
hi! link SpecialChar	Special
hi! link Delimiter	Special
hi! link SpecialComment Special
hi! link Debug		Special

" HTML 
hi htmlLink                 gui=UNDERLINE guifg=#0000ff guibg=NONE
hi htmlBold                 gui=BOLD
hi htmlBoldItalic           gui=BOLD,ITALIC
hi htmlBoldUnderline        gui=BOLD,UNDERLINE
hi htmlBoldUnderlineItalic  gui=BOLD,UNDERLINE,ITALIC
hi htmlItalic               gui=ITALIC
hi htmlUnderline            gui=UNDERLINE
hi htmlUnderlineItalic      gui=UNDERLINE,ITALIC
