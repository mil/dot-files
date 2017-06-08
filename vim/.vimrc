" Install pathogen
execute pathogen#infect() 

" Rainbow Parens
let g:rainbow_active = 1
let g:rainbow_conf = {
\   'ctermfgs': ['16', '17', '18', '25'],
\   'operators': '_,_',
\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold']
\}


"Encoding
set encoding=utf-8

" Perf-related
set ttyfast
set ttyscroll=3
set lazyredraw

set showcmd " display incomplete commands
filetype plugin indent on " load file type plugins + indentation

" Whitespace
set wrap
set linebreak
set nolist
set backspace=indent,eol,start
set textwidth=0
set wrapmargin=0
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

"" Searching
set hlsearch " highlight matches
set incsearch " incremental searching
set ignorecase " searches are case insensitive...
set smartcase " ... unless they contain at least one capital letter
set number " show line numbers!
set ai " auto identing


" Maps arrows keys to move status bar/splits
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>
map <up> <c-w>-
map <down> <c-w>+
map <right> <c-w>>
map <left> <c-w><

nnoremap gp `[v`]


" Colorscheme Related
set t_Co=256
colorscheme louver
syntax enable

" set list!
set listchars=tab:+-
set cursorline
set mouse=nv


" Backup Dir
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp  

" Fix the * Clipboard
set clipboard=unnamed

if version >= 700
	au InsertEnter * hi StatusLine term=reverse ctermbg=2
	au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=7
endif

" Status Bar
set laststatus=2  " always show the status bar
set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file


map <C-C> :Eval<CR>
map <C-X> :Eval (stop)<CR>

set foldlevel=3000

" Show trailing whitespace and spaces before a tab:
highlight ExtraWhitespace ctermbg=green guibg=green
match ExtraWhitespace /\s\+$\| \+\ze\t/

" Shows over 80cols as red
highlight OverLength ctermbg=red ctermfg=white
match OverLength /\%81v.\+/



command! EnablePiggieback :Piggieback (adzerk.boot-cljs-repl/repl-env)
command! Figwheel :Piggieback! (do (require 'figwheel-sidecar.repl-api) (figwheel-sidecar.repl-api/cljs-repl))

au BufRead,BufNewFile *.boot setfiletype clojure
hi MatchParen cterm=none ctermbg=green ctermfg=black


:hi Insert ctermbg=2
:hi Search ctermbg=Yellow
:hi IncSearch ctermbg=Cyan
:hi Pmenu ctermbg=Yellow
:hi PmenuSel ctermbg=Green
:hi SpecialKey ctermbg=none ctermfg=gray

let g:sclangTerm = "urxvt"
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']


let g:go_fmt_command = "goimports"


"set list
"set listchars=tab:+>
