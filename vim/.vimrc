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

hi clear CursorLine
hi CursorLine   ctermbg=lightgray

" Backup Dir
"set backup
"set backupdir=~/.vim/backup
"set directory=~/.vim/tmp
set noswapfile

" Fix the * Clipboard
set clipboard=unnamedplus

if version >= 700
  au InsertEnter * hi StatusLine term=reverse ctermbg=green ctermfg=white
  au InsertLeave * hi StatusLine term=reverse ctermbg=blue
endif
hi MatchParen cterm=none ctermbg=green ctermfg=black
hi Insert ctermbg=2
hi Search ctermbg=Yellow
hi IncSearch ctermbg=Cyan
hi Pmenu ctermbg=White
hi PmenuSel ctermbg=Green
hi SpecialKey ctermbg=none ctermfg=gray

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
set statusline+=%m      "modified flag


" Show trailing whitespace and spaces before a tab:
" Shows over 80cols as red
"set list
highlight ExtraWhitespace ctermbg=green guibg=green
match ExtraWhitespace /\s\+$\| \+\ze\t/
set colorcolumn=80
"set textwidth=80
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set foldlevel=3000


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TF
let g:terraform_fmt_on_save = 1
" Go
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:go_fmt_command = "goimports"
source ~/.vim/bundle/vim-go/autoload/go/doc.vim
" SC
let g:sclangTerm = "termite -e"
let g:scFlash = 1
au Filetype supercollider nnoremap <buffer> <C-C> :call SClang_block()<CR>
au Filetype supercollider inoremap <buffer> <C-C> :call SClang_block()<CR>a
au Filetype supercollider vnoremap <buffer> <C-C> :call SClang_send()<CR>
au Filetype supercollider nnoremap <buffer> <C-S> :call SClangHardstop()<CR>

command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'
autocmd BufWritePost /home/mil/Mixtapes/Programming/*.sc Silent oscsend localhost 57120 /reloadProgramming
autocmd BufWritePost /home/mil/Mixtapes/Library/*.sc Silent oscsend localhost 57120 /reloadLibrary

map <C-o> mzvi[:!colfmt<CR>vi[:>><CR>:redraw!<CR>`z
map fd mzvi[:!colfmt<CR>vi[:>><CR>:redraw!<CR>`z
map ff :w! <CR>

map ft  :Silent oscsend localhost 57120 /runTests<CR>
map fr :w! <CR> :Silent oscsend localhost 57120 /reloadProgramming<CR>
map fe :w! <CR> :Silent oscsend localhost 57120 /reloadLibrary<CR>

set incsearch
