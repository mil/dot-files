set nocompatible                " choose no compatibility with 
"set legacy vi

set ttyfast
set ttyscroll=3
set lazyredraw

syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set wrap                      " don't wrap lines
set linebreak
set nolist
set backspace=indent,eol,start  " backspace through everything in insert mode
set textwidth=0
set wrapmargin=0

set tabstop=2 
set softtabstop=2
set shiftwidth=2
set expandtab

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter
set smartindent
set number     " show line numbers!
set ai          " Auto identing

"" No more arrow keys
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" Easy Resize
map <up> <c-w>-
map <down> <c-w>+
map <right> <c-w>>
map <left> <c-w><

" 256 Colors with Wombat
set t_Co=256
colorscheme louver
"colorscheme Mustang

" set list!
set listchars=tab:+-
" trail:.,precedes:<,extends:>,eol:$
"

function Dark()
	:colorscheme Mustang 
endfunction

command Light colorscheme summerfruit256 
command Dark exec Dark() 
"command Dark  colorscheme custom 
" Cursorline 
set cursorline
"set cursorcolumn

" Mouse for Normal and Visual Mode only
set mouse=nv

set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp  

" Fix the * Clipboard
set clipboard=unnamed

set wildmenu "Tab completion status bar

"call pathogen#helptags()
"call pathogen#runtime_append_all_bundles()
"call pathogen#infect()


" Colored Statusbar for Inser/Command
" first, enable status line always
"set laststatus=2

" now set it up to change the status line based on mode
if version >= 700
	au InsertEnter * hi StatusLine term=reverse ctermbg=2 gui=undercurl guisp=Magenta
	"au InsertEnter * silent ! insertMode & 
	au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=7 gui=bold,reverse
"	au InsertLeave * silent ! clearMode &

"	au FocusLost * silent !clearMode &
endif
:hi ModeMsg ctermbg=0 ctermfg=7 gui=bold


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



set foldlevel=3000
"set mouse=a
"
"highlight OverLength ctermbg=none ctermfg=red
"match OverLength /\%81v.\+/

