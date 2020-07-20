" ==== Plugins =================================================

call plug#begin()

" Visual
Plug 'itchyny/lightline.vim'
"Plug 'bling/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'chriskempson/base16-vim'

" Languages
Plug 'sheerun/vim-polyglot'
Plug 'w0rp/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Utilities
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-scripts/a.vim'
Plug 'aperezdc/vim-template'
Plug 'tpope/vim-surround'

if has('nvim')
	Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
	Plug 'Shougo/denite.nvim'
	Plug 'roxma/nvim-yarp'
	Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()


" ==== General =================================================

set autoread       " reload files changed outside of vim
set hidden
set nobackup       " not vim's job, rely on git for backups
set noswapfile
set noshowmode
set nowritebackup
set nomodeline     " disable modelines for security reasons


" ==== Indentation =============================================

set autoindent
set smartindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab

" Auto indent pasted text TODO: fix this
" nnoremap p p=`]<C-o>
" nnoremap P P=`]<C-o>

filetype plugin indent on

set nowrap


" ==== Colors ==================================================

syntax on
set termguicolors
set background=dark
let base16colorspace=256
colorscheme base16-google-dark
set t_Co=256
let g:rehash256 = 1


" ==== User Interface ==========================================

set number                  " show line numbers
hi CursorLineNr cterm=NONE
set ruler                   " show cursor position
set cursorline              " highlight the current line
set showmatch               " highlight matching braces/brackets/parens
set wildmenu                " visual autocomplete for ex commands
set lazyredraw              " only readraw when necessary
set formatoptions=tcqrnj    " see fo-table for details
set laststatus=2            " always show status bar

" Display tabs and trailing spaces visually.
set list listchars=tab:\\ ,trail:·


" ================ Scrolling ========================

set scrolloff=8       " start scrolling when we're 8 lines away from margins
set sidescrolloff=15


" ==== History =================================================

set history=1000
set undolevels=1000
set timeoutlen=1000
set ttimeoutlen=10


" ==== Search ==================================================

set incsearch
set hlsearch
set ignorecase
set smartcase


" ==== Folds ===================================================

set foldenable
set foldmethod=indent
set foldlevelstart=20  " show 20 levels of indentation by default
nnoremap <space> za    " press space to toggle folding


" ==== Movement ================================================

nnoremap j gj
nnoremap k gk
nnoremap B ^
nnoremap E $

nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l


" ==== Leader Remaps ===========================================

nnoremap <cr> :nohlsearch<cr>

let mapleader=","
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>es :vsp ~/.zshrc<CR>
nnoremap <leader>r :set relativenumber!<CR>
nnoremap <leader>c I//<ESC>
map <silent> <leader>h :bprevious<cr>
map <silent> <leader>l :bnext<cr>


" ==== ALE =====================================================

let g:ale_echo_msg_format = '%linter%: %s'
let g:ale_sign_error = "✗"
let g:ale_sign_warning = "⚠"
let b:ale_linters = {'rust': ['rls','cargo','rustc']}
let g:ale_fixers = {'rust': ['rustfmt']}
let g:ale_rust_rls_toolchain = 'stable'

" Map keys to navigate between lines with errors and warnings.
nnoremap <leader>an :ALENextWrap<cr>
nnoremap <leader>ap :ALEPreviousWrap<cr>


" ==== CoC =====================================================

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction


" ==== Other Plugins ===========================================

"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1
"let g:airline_theme = 'base16'
let g:lightline = {
	\ 'colorscheme': 'wombat',
	\ }

let g:dart_style_guide = 2
let g:dart_format_on_save = 1

for f in argv()
	if isdirectory(f)
		echomsg 'vimrc: Cowardly refusing to edit directory ' . f
		quit
	endif
endfor

let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
