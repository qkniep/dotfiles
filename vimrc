" --------------------------------------------------------------
" General
" --------------------------------------------------------------

set enc=utf-8
set fenc=utf-8
set termencoding=utf-8

set nocompatible
set nobackup
set noswapfile
set noshowmode

"filetype off


" --------------------------------------------------------------
" Indentation
" --------------------------------------------------------------

set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
filetype plugin indent on


" --------------------------------------------------------------
" Plugins
" --------------------------------------------------------------

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"Plugin 'morhetz/gruvbox'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'vim-scripts/a.vim'
"Plugin 'Shougo/unite.vim'
"Plugin 'mhinz/vim-startify'

Plugin 'gmarik/Vundle.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/syntastic'
Plugin 'SirVer/ultisnips'
Plugin 'aperezdc/vim-template'
Plugin 'vim-scripts/cscope.vim'
Plugin 'tpope/vim-surround'
Plugin 'mattn/emmet-vim'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'chriskempson/base16-vim'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-notes'

call vundle#end()


" --------------------------------------------------------------
" Colors
" --------------------------------------------------------------

syntax enable
set background=dark
let base16colorspace=256
colorscheme base16-google-dark
set term=screen-256color
set t_Co=256
hi LineNr ctermfg=grey
let g:rehash256 = 1


" --------------------------------------------------------------
" User Interface
" --------------------------------------------------------------

set number                " show line numbers
set cursorline            " highlight the current line
"set showmatch            " highlight matching braces/brackets/parens
let loaded_matchparen = 0 " disable highlighting of matching <,(,{,[
set wildmenu              " visual autocomplete for ex commands
set list lcs=tab:\|\      " show level of indentation
set textwidth=120         "
"set colorcolumn=120      " highlight max row length


" --------------------------------------------------------------
" Status Bar
" --------------------------------------------------------------

set laststatus=2                               " always show status bar
"set statusline+=%#warningmsg#                 "
"set statusline+=%{SyntasticStatuslineFlag()}  "
"set statusline+=%*                            "


" --------------------------------------------------------------
" History
" --------------------------------------------------------------

set history=1000
set undolevels=1000
set timeoutlen=1000
set ttimeoutlen=10


" --------------------------------------------------------------
" Search
" --------------------------------------------------------------

set ignorecase
set smartcase
set hlsearch
set incsearch


" --------------------------------------------------------------
" Folds
" --------------------------------------------------------------

set foldenable         " enable folding
set foldmethod=indent  " fold by indentation
set foldlevelstart=10  " show 10 levels of indentation by default
nnoremap <space> za    " press space to toggle folding


" --------------------------------------------------------------
" Movement
" --------------------------------------------------------------

"nnoremap j gj
"nnoremap k gk
"nnoremap B ^
"nnoremap E $
"nnoremap $ <nop>
"nnoremap ^ <nop>


" --------------------------------------------------------------
" Syntastic
" --------------------------------------------------------------

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_cpp_include_dirs = [ 'Header/' ]
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_compiler = "g++"
let g:syntastic_cpp_compiler_options = " -std=c++11"


" --------------------------------------------------------------
" Airline
" --------------------------------------------------------------

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16'

"let g:ycm_show_diagnostics_ui = 0
let g:templates_directory = '~/dotfiles/vim/templates/'
