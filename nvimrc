" ==== Plugins =================================================

call plug#begin()

" Visual
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
"Plug 'bling/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'chriskempson/base16-vim'
Plug 'mike-hearn/base16-vim-lightline'

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
set shada=!,'100,<1000,s100,h


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


" ==== Scrolling ===============================================

set scrolloff=8       " start scrolling 8 lines away from margins
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


" ==== Denite ==================================================

try

call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])
call denite#custom#var('grep', 'command', ['rg'])

" Custom options for ripgrep
"   --vimgrep:  Show results with every match on it's own line
"   --hidden:   Search hidden directories and files
"   --heading:  Show the file name above clusters of matches from each file
"   --S:        Search case insensitively if the pattern is all lowercase
call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

" Recommended defaults for ripgrep via Denite docs
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Remove date from buffer list
call denite#custom#var('buffer', 'date_format', '')

let s:denite_options = {'default' : {
\ 'split': 'floating',
\ 'start_filter': 1,
\ 'auto_resize': 1,
\ 'source_names': 'short',
\ 'prompt': 'λ ',
\ 'highlight_matched_char': 'QuickFixLine',
\ 'highlight_matched_range': 'Visual',
\ 'highlight_window_background': 'Visual',
\ 'highlight_filter_background': 'DiffAdd',
\ 'winrow': 1,
\ 'vertical_preview': 1
\ }}

function! s:profile(opts) abort
	for l:fname in keys(a:opts)
		for l:dopt in keys(a:opts[l:fname])
			call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
		endfor
	endfor
endfunction

call s:profile(s:denite_options)
catch
	echo 'Denite not installed. It should work after running :PlugInstall'
endtry

nmap ; :Denite buffer<CR>
nmap <leader>t :DeniteProjectDir file/rec<CR>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<CR>

" Define mappings while in 'filter' mode
"   <C-o>         - Switch to normal mode inside of search results
"   <Esc>         - Exit denite window in any mode
"   <CR>          - Open currently selected file in any mode
"   <C-t>         - Open currently selected file in a new tab
"   <C-v>         - Open currently selected file a vertical split
"   <C-h>         - Open currently selected file in a horizontal split
autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
	imap <silent><buffer> <C-o>
	\ <Plug>(denite_filter_quit)
	inoremap <silent><buffer><expr> <Esc>
	\ denite#do_map('quit')
	nnoremap <silent><buffer><expr> <Esc>
	\ denite#do_map('quit')
	inoremap <silent><buffer><expr> <CR>
	\ denite#do_map('do_action')
	inoremap <silent><buffer><expr> <C-t>
	\ denite#do_map('do_action', 'tabopen')
	inoremap <silent><buffer><expr> <C-v>
	\ denite#do_map('do_action', 'vsplit')
	inoremap <silent><buffer><expr> <C-h>
	\ denite#do_map('do_action', 'split')
endfunction

" Define mappings while in denite window
"   <CR>        - Opens currently selected file
"   q or <Esc>  - Quit Denite window
"   d           - Delete currenly selected file
"   p           - Preview currently selected file
"   <C-o> or i  - Switch to insert mode inside of filter prompt
"   <C-t>       - Open currently selected file in a new tab
"   <C-v>       - Open currently selected file a vertical split
"   <C-h>       - Open currently selected file in a horizontal split
autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
	nnoremap <silent><buffer><expr> <CR>
	\ denite#do_map('do_action')
	nnoremap <silent><buffer><expr> q
	\ denite#do_map('quit')
	nnoremap <silent><buffer><expr> <Esc>
	\ denite#do_map('quit')
	nnoremap <silent><buffer><expr> d
	\ denite#do_map('do_action', 'delete')
	nnoremap <silent><buffer><expr> p
	\ denite#do_map('do_action', 'preview')
	nnoremap <silent><buffer><expr> i
	\ denite#do_map('open_filter_buffer')
	nnoremap <silent><buffer><expr> <C-o>
	\ denite#do_map('open_filter_buffer')
	nnoremap <silent><buffer><expr> <C-t>
	\ denite#do_map('do_action', 'tabopen')
	nnoremap <silent><buffer><expr> <C-v>
	\ denite#do_map('do_action', 'vsplit')
	nnoremap <silent><buffer><expr> <C-h>
	\ denite#do_map('do_action', 'split')
endfunction


" ==== Other Plugins ===========================================

"let g:airline#extensions#tabline#enabled = 1
"let g:airline_powerline_fonts = 1
"let g:airline_theme = 'base16'
let g:lightline = {
\   'colorscheme': '16color',
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
