" Sets how many lines of history VIM has to remember
set history=700
set nocompatible

" Enable filetype plugins
" filetype plugin on
" filetype indent on
filetype off


set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-surround'
Plugin 'Raimondi/delimitMate'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'Shougo/neocomplcache.vim'


call vundle#end()
filetype plugin indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader =","
let g:mapleader= ","


" VIM user interface

" height of the command bar
set cmdheight=2

" Configure the backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

"Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

"Show matching brackets when text indicator is over them
set showmatch

"How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on erros
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Colors and Fonts
syntax enable

colorscheme desert
set background=dark
set nu

let g:indent_guides_guide_size = 1

" Set utf8 as standard encoding and en_US as the standard language
"set encoding=utf8

" Text, tab and indent rules

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs 
set smarttab

" 1 tab = 4 spaces
set shiftwidth=4
set tabstop=4

" Linerbreak on 500 characters
set lbr
set tw =500

"Auto indent, smart indent, wrap lines
set ai
set si
set wrap

" map space to search and ctrl + space to backwards search
map <space> /
map <c-space> ?


" Return to last edit position when opening files

autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%


