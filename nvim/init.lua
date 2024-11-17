vim.g.mapleader = ' '

-- basic UI settings
vim.o.background = 'dark'
vim.o.termguicolors = true
vim.o.guicursor = ''
vim.o.number = true
vim.o.scrolloff = 8

-- indentation and line wrapping
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.wrap = false

vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 200
vim.o.timeoutlen = 300

vim.keymap.set('n', '<leader><CR>', '<cmd>terminal cargo run --release<CR>')

vim.keymap.set('n', 'J', 'mzJ`z')

vim.keymap.set('n', '<Esc>', ':noh<CR>')

-- move current selection around
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')

-- yank into system register
vim.keymap.set('n', '<leader>y', '\"+y')
vim.keymap.set('v', '<leader>y', '\"+y')

-- delete into void register
vim.keymap.set('n', '<leader>d', '\"_d')
vim.keymap.set('v', '<leader>d', '\"_d')

vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>k', '<cmd>lprev<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		dependencies = {
			-- LSP Support
			'neovim/nvim-lspconfig',    -- Required
			'williamboman/mason.nvim',  -- Optional
			'williamboman/mason-lspconfig.nvim', -- Optional
			-- Autocompletion
			'hrsh7th/nvim-cmp',         -- Required
			'hrsh7th/cmp-nvim-lsp',     -- Required
			'L3MON4D3/LuaSnip',         -- Required
		}
	},
	{
		'j-hui/fidget.nvim',
		tag = 'legacy',
		event = 'LspAttach',
		opts = {
			text = {
				spinner = 'dots',
				done = '✓',
			}
		},
	},
	{
		'Everblush/nvim',
		name = 'everblush',
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd('colorscheme everblush')
		end
	},
	-- {
	-- 	'f4z3r/gruvbox-material.nvim',
	-- 	name = 'gruvbox-material',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd('colorscheme gruvbox-material')
	-- 	end
	-- },
	-- {
	-- 	'ellisonleao/gruvbox.nvim',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.cmd('colorscheme gruvbox')
	-- 	end
	-- },
	-- {
	-- 	'ribru17/bamboo.nvim',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require('bamboo').setup {
	-- 			-- optional configuration here
	-- 		}
	-- 		require('bamboo').load()
	-- 	end,
	-- },
	-- {
	-- 	'folke/tokyonight.nvim',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {},
	-- 	config = function()
	-- 		vim.cmd('colorscheme tokyonight-night')
	-- 		vim.cmd('hi MsgArea guibg=#15161e')
	-- 	end
	-- },
	-- {
	-- 	'rebelot/kanagawa.nvim',
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	opts = {},
	-- 	config = function()
	-- 		require('kanagawa').setup({
	-- 			terminalColors = true,
	-- 			theme = "wave",
	-- 			colors = {
	-- 				theme = {
	-- 					all = {
	-- 						ui = {
	-- 							bg_gutter = "none"
	-- 						}
	-- 					}
	-- 				}
	-- 			},
	-- 		})
	-- 		vim.cmd('colorscheme kanagawa-wave')
	-- 	end
	-- },
	{
		'folke/trouble.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			use_diagnostic_signs = true,
		},
	},
	{
		'folke/todo-comments.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {
			highlight = {
				pattern = [[.*<(KEYWORDS)\s*(\(\@?\w*\))?\s*:?]],
			},
		},
	},
	{
		'Darazaki/indent-o-matic'
	},
	{
		'lukas-reineke/indent-blankline.nvim',
		main = 'ibl',
		---@module 'ibl'
		---@type ibl.config
		opts = {
			indent = {
				char = '│',
				highlight = 'LineNr',
			},
			whitespace = {
				highlight = 'LineNr',
			},
			scope = {
				enabled = true,
				highlight = 'Comment',
				priority = 1024,
			},
		},
	},
	{
		'terrortylor/nvim-comment',
		init = function()
			require('nvim_comment').setup()
		end,
	},
	'rvmelkonian/move.vim',
	'tpope/vim-fugitive',
	'tpope/vim-rhubarb',
	'lewis6991/gitsigns.nvim',
	'nvim-lualine/lualine.nvim',
	'nvim-treesitter/nvim-treesitter',
	'mbbill/undotree',
	'theprimeagen/harpoon',
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.2',
		cmd = 'Telescope',
		dependencies = { 'nvim-lua/plenary.nvim' },
		init = function()
			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<C-p>', builtin.git_files, {})
			vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
			vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
			vim.keymap.set('n', '<leader>fd', builtin.lsp_document_symbols, {})
			vim.keymap.set('n', '<leader>fw', builtin.lsp_workspace_symbols, {})
			vim.keymap.set('n', '<leader>fe', builtin.diagnostics, {})
		end,
	},
	{
		'nvim-neo-tree/neo-tree.nvim',
		branch = 'v3.x',
		cmd = 'Telescope',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
			'MunifTanjim/nui.nvim',
		}
	},
	{
		'Exafunction/codeium.nvim',
		event = 'BufEnter',
		config = function()
			-- require('codeium').setup({
			-- 	enable_chat = true
			-- })
			vim.keymap.set('i', '<C-c>', function() return vim.fn['codeium#Complete']() end, { expr = true })
			vim.keymap.set('i', '<C-j>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
			vim.keymap.set('i', '<C-k>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
			vim.keymap.set('i', '<C-a>', function() return vim.fn['codeium#Accept']() end, { expr = true })
			vim.keymap.set('i', '<C-x>', function() return vim.fn['codeium#Clear']() end, { expr = true })
		end
	},
	{
		"David-Kunz/gen.nvim",
		opts = {
			model = "qwen2.5-coder:7b",
		},
	},
	{
		'melbaldove/llm.nvim',
		dependencies = { 'nvim-neotest/nvim-nio' },
		-- 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
		config = function()
			vim.keymap.set("n", "<leader>,", function() require("llm").prompt({ replace = false, service = "groq" }) end,
				{ desc = "Prompt with groq" })
			vim.keymap.set("v", "<leader>,", function() require("llm").prompt({ replace = false, service = "groq" }) end,
				{ desc = "Prompt with groq" })
			vim.keymap.set("v", "<leader>.", function() require("llm").prompt({ replace = true, service = "groq" }) end,
				{ desc = "Prompt while replacing with groq" })
		end
	},
	{
		'Julian/lean.nvim',
		event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

		dependencies = {
			'neovim/nvim-lspconfig',
			'nvim-lua/plenary.nvim',
			'hrsh7th/nvim-cmp',
		},
	},
})

-- require('gruvbox-material').setup({
-- 	italics = true, -- enable italics in general
-- 	contrast = 'hard',
-- })

local lsp = require('lsp-zero').preset('recommended')

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
	lsp.async_autoformat(client, bufnr)

	vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
	vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
end)

lsp.set_sign_icons({
	error = '✘',
	warn = '',
	hint = '⚑',
	info = '»',
})

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

local cmp = require('cmp')

cmp.setup({
	mapping = {
		['<CR>'] = cmp.mapping.confirm({ select = false }),
	},
	sources = {
		{ name = 'codeium' }
	},
})

require('codeium').setup({})

vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

vim.keymap.set('n', '<leader>n', vim.cmd.Neotree)

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

require('nvim-treesitter.configs').setup {
	ensure_installed = {
		'javascript', 'typescript', 'css', 'html', 'svelte',
		'c', 'cpp', 'python', 'lua', 'rust', 'go', 'haskell',
		'dockerfile', 'json', 'yaml', 'toml', 'bash', 'fish',
		'latex', 'ocaml', 'zig'
	},
	auto_update = true,
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = '<C-space>',
			node_incremental = '<C-space>',
			scope_incremental = '<C-s>',
			node_decremental = '<C-backspace>',
		},
	},
}

local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

vim.keymap.set('n', '<leader>a', mark.add_file)
vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)
vim.keymap.set('n', '<C-h>', function() ui.nav_file(1) end)
vim.keymap.set('n', '<C-t>', function() ui.nav_file(2) end)
vim.keymap.set('n', '<C-n>', function() ui.nav_file(3) end)
vim.keymap.set('n', '<C-s>', function() ui.nav_file(4) end)

-- lualine setup
require('lualine').setup {
	options = {
		theme = 'everblush',
		component_separators = '',
		section_separators = { left = '', right = '' },
	},
	sections = {
		lualine_a = {
			{ 'mode', separator = { left = '' }, right_padding = 2 },
		},
		lualine_b = { 'filename' },
		lualine_c = {
			{ 'branch', icon = '' },
			{
				'diff',
				symbols = { added = ' ', modified = ' ', removed = ' ' },
			},
		},
		lualine_x = {
			{
				'diagnostics',
				symbols = {
					error = '✘ ',
					warn = ' ',
					hint = '⚑ ',
					info = '» ',
				},
			},
			{
				function()
					local msg = ''
					local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
					local clients = vim.lsp.get_active_clients()
					if next(clients) == nil then
						return msg
					end
					for _, client in ipairs(clients) do
						local filetypes = client.config.filetypes
						if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
							return client.name
						end
					end
					return msg
				end,
				icon = '',
			},
		},
		lualine_y = { 'filetype' },
		lualine_z = {
			{ 'location', separator = { right = '' }, left_padding = 2 },
		},
	},
	inactive_sections = {
		lualine_a = { 'filename' },
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { 'location' },
	},
	tabline = {},
	extensions = {},
}

local git_char = '┃'
require('gitsigns').setup {
	signs = {
		add = { text = git_char },
		change = { text = git_char },
		delete = { text = git_char },
		topdelete = { text = git_char },
		changedelete = { text = git_char },
		untracked = { text = git_char },
	},
	signcolumn = true,
	numhl = false,
}
