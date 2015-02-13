set enc=utf-8
set fenc=utf-8
set termencoding=utf-8

set nocompatible
set nobackup
set noswapfile
set noshowmode

set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab

set textwidth=120
"set colorcolumn=120

filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Bundle 'chriskempson/base16-vim'
Bundle 'zeis/vim-kolor'
Bundle 'morhetz/gruvbox'
Bundle 'Valloric/YouCompleteMe'
Bundle 'scrooloose/syntastic'
Bundle 'vim-scripts/a.vim'
Bundle 'SirVer/ultisnips'
Bundle 'vim-scripts/cscope.vim'
Bundle 'Shougo/unite.vim'
Bundle 'kien/ctrlp.vim'
Bundle 'rking/ag.vim'
Bundle 'Yggdroot/indentLine'
"Bundle 'airblade/vim-gitgutter'
Bundle 'tpope/vim-fugitive'
Bundle 'bling/vim-airline'

call vundle#end()
filetype plugin indent on

syntax enable

set background=dark
"colorscheme base16-default
"colorscheme kolor
colorscheme gruvbox
set term=screen-256color
set t_Co=256
hi LineNr ctermfg=grey
"set base16colorspace=256
let g:rehash256 = 1

set title
set number
set showmatch

set history=1000
set undolevels=1000

set ignorecase
set smartcase
set hlsearch
set incsearch

set laststatus=2
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_cpp_include_dirs = [ 'Header/' ]
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_remove_include_errors = 1

let g:indentLine_color_term = 8

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16'
