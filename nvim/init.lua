vim.opt.termguicolors = true

-- Plugins

require('plugins')
require('lsp')
require('statusline')


-- General

vim.opt.autoread = true -- reload files changed outside of vim
vim.opt.hidden = true
vim.opt.backup = false -- not vim's job, rely on git for backups
vim.opt.swapfile = false
vim.opt.showmode = false
vim.opt.writebackup = false
vim.opt.modeline = false -- disable modelines for security reasons
vim.opt.shada = "!,'100,<1000,s100,h"


-- Indentation

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.cmd([[filetype plugin indent on]])

vim.opt.wrap = false


-- Colors

vim.opt.background = 'dark'
vim.cmd([[colorscheme srcery]])
vim.g.srcery_italic = 1
vim.g.srcery_inverse_match_paren = 1
vim.g.base16colorspace = 256

vim.cmd [[highlight! link DiagnosticError SrceryRed]]
vim.cmd [[highlight! link DiagnosticWarn SrceryYellow]]
vim.cmd [[highlight! link DiagnosticInfo SrceryBlue]]
vim.cmd [[highlight! link DiagnosticHint SrceryGreen]]


-- UI

vim.opt.number = true -- show line numbers
vim.opt.ruler = true -- show cursor position
vim.opt.cursorline = true -- highlight the current line
vim.opt.showmatch = true -- highlight matching braces/brackets/parens
vim.opt.wildmenu = true -- visual autocomplete for ex commands
vim.opt.lazyredraw = true -- only readraw when necessary
vim.opt.formatoptions = 'tcqrnj' -- see fo-table for details
vim.opt.laststatus = 2 -- always show status bar

-- Display tabs and trailing spaces visually.
vim.opt.list = true
vim.opt.listchars = { tab = '│ ', trail = '·' }

vim.g.indentLine_fileTypeExclude = { 'markdown', 'latex', 'tex', 'csv', 'dockerfile' }
vim.g.indentLine_setColors = 1
vim.g.indentLine_showFirstIndentLevel = 1
vim.g.indentLine_char = '│'
vim.g.indentLine_first_char = '│'


-- Scrolling

vim.opt.scrolloff = 8 -- start scrolling 8 lines away from margins
vim.opt.sidescrolloff = 15


-- History

vim.opt.history = 1000
vim.opt.undolevels = 1000
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 10


-- Search

vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true


-- Folds

vim.opt.foldenable = true
vim.opt.foldmethod = 'indent'
vim.opt.foldlevelstart = 20 -- show 20 levels of indentation by default
-- TODO nnoremap <space> za    -- press space to toggle folding


-- Movement

vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })
vim.keymap.set('n', 'B', '^', { noremap = true })
vim.keymap.set('n', 'E', '$', { noremap = true })

vim.keymap.set('n', '<C-j>', '<C-W>j', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-W>k', { noremap = true })
vim.keymap.set('n', '<C-h>', '<C-W>h', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-W>l', { noremap = true })


-- Leader Remaps

--nnoremap <cr> :nohlsearch<cr>

vim.g.mapleader = ','
--nnoremap <leader>ev :vsp $MYVIMRC<CR>
--nnoremap <leader>sv :source $MYVIMRC<CR>
--nnoremap <leader>es :vsp ~/.zshrc<CR>
--nnoremap <leader>r :set relativenumber!<CR>
--nnoremap <leader>c I//<ESC>
--map <silent> <leader>h :bprevious<cr>
--map <silent> <leader>l :bnext<cr>


-- Miscellaneous

-- disable gd shortcut for vim-go, let nvim-lspconfig handle this
vim.g.go_def_mapping_enabled = 0

vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*', 'scp://.*' }

vim.g.gitgutter_sign_added                   = '┃'
vim.g.gitgutter_sign_modified                = '┃'
vim.g.gitgutter_sign_removed                 = '┃'
vim.g.gitgutter_sign_removed_first_line      = '┃'
vim.g.gitgutter_sign_removed_above_and_below = '╏'
vim.g.gitgutter_sign_modified_removed        = '┃'
