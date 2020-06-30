" --------------------------------------------------------------
" Plugins
" --------------------------------------------------------------

call plug#begin()

"Plug 'wincent/command-t'
"Plug 'Shougo/unite.vim'
"Plug 'vim-scripts/cscope.vim'
"Plug 'mattn/emmet-vim'
"Plug 'SirVer/ultisnips'
"Plug 'scrooloose/syntastic'

" Visual
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'chriskempson/base16-vim'

Plug 'w0rp/ale'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-scripts/a.vim'
Plug 'aperezdc/vim-template'
Plug 'tpope/vim-surround'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'
Plug 'sheerun/vim-polyglot'

call plug#end()


" --------------------------------------------------------------
" General
" --------------------------------------------------------------

set autoread       " reload files changed outside of vim
set nobackup       " not vim's job, rely on git for backups
set noswapfile
set noshowmode
set nowritebackup
set nomodeline     " disable modelines for security reasons


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
" Colors
" --------------------------------------------------------------

syntax on
set background=dark
let base16colorspace=256
colorscheme base16-google-dark
set t_Co=256
let g:rehash256 = 1


" --------------------------------------------------------------
" User Interface
" --------------------------------------------------------------

set number                " show line numbers
hi CursorLineNr cterm=NONE
set ruler                 " show cursor position
set cursorline            " highlight the current line
set showmatch             " highlight matching braces/brackets/parens
set wildmenu              " visual autocomplete for ex commands
set lazyredraw            " only readraw when necessary
set list lcs=tab:\       " show level of indentation
"set list lcs=tab:\|\     " show level of indentation
"set textwidth=80          "
set nowrap
"set colorcolumn=+1       " highlight max row length
set formatoptions=tcqrnj  " see fo-table for details


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

set foldenable
set foldmethod=indent
set foldlevelstart=20  " show 10 levels of indentation by default
nnoremap <space> za    " press space to toggle folding


" --------------------------------------------------------------
" Movement
" --------------------------------------------------------------

nnoremap j gj
nnoremap k gk
nnoremap B ^
nnoremap E $

nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l


" --------------------------------------------------------------
" Leader Commands
" --------------------------------------------------------------

nnoremap <cr> :nohlsearch<cr>

let mapleader=","
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>es :vsp ~/.zshrc<CR>
nnoremap <leader>r :set relativenumber!<CR>
nnoremap <leader>c I//<ESC>
map <silent> <leader>h :bprevious<cr>
map <silent> <leader>l :bnext<cr>


" --------------------------------------------------------------
" Filetype Specific Settings
" --------------------------------------------------------------

autocmd FileType sh setlocal expandtab


" --------------------------------------------------------------
" Syntastic
" --------------------------------------------------------------

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
" C++ related Syntastic settings
"let g:syntastic_cpp_check_header = 1
"let g:syntastic_cpp_include_dirs = [ 'include' ]
"let g:syntastic_cpp_compiler = 'g++'
"let g:syntastic_cpp_compiler_options = '-std=c++17 -Wall -Wextra'
" Hide LaTeX warning about spaces after commands.
"let g:syntastic_quiet_messages = { 'regex': ['Command terminated with space.', 'space in front of parenthesis'] }


" --------------------------------------------------------------
" Other
" --------------------------------------------------------------

let g:ale_echo_msg_format = '%linter%: %s'
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "⚠"
let b:ale_linters = {'rust': ['rls','cargo','rustc']}
let g:ale_fixers = {'rust': ['rustfmt']}
let g:ale_rust_rls_toolchain = 'stable'
" Map keys to navigate between lines with errors and warnings.
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'base16'

"let dart_html_in_string=v:true
let g:dart_style_guide = 2
let g:dart_format_on_save = 1

for f in argv()
	if isdirectory(f)
		echomsg 'vimrc: Cowardly refusing to edit directory ' . f
		quit
	endif
endfor
