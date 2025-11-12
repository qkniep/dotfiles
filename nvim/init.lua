vim.keymap.set('n', ' ', '<Nop>', { silent = true, remap = false })
vim.g.mapleader = ' '

-- basic UI settings
vim.o.background = 'dark'
vim.o.termguicolors = true
vim.o.guicursor = ''
vim.o.number = true
vim.o.scrolloff = 4

-- indentation and line wrapping
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.wrap = false

vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true

-- case sensitivity of search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 200
vim.o.timeoutlen = 300

vim.keymap.set('n', '<leader><CR>', '<cmd>Cargo nextest run --all-targets<CR>')

vim.keymap.set('n', 'J', 'mzJ`z')        -- join current and following line
vim.keymap.set('n', '<Esc>', ':noh<CR>') -- reset search highlighting

-- move current selection around
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')

-- yank into system register
vim.keymap.set('n', '<leader>y', '\"+y')
vim.keymap.set('v', '<leader>y', '\"+y')

-- delete into void register
vim.keymap.set('n', '<leader>d', '\"_d')
vim.keymap.set('v', '<leader>d', '\"_d')

-- cycle through diagnostics (warnings/errors)
vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')

-- cycle through location list
vim.keymap.set('n', '<leader>k', '<cmd>lprev<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

-- setup for Lazy plugin manager
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
		branch = 'v4.x',
		dependencies = {
			-- LSP support
			'neovim/nvim-lspconfig',
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'L3MON4D3/LuaSnip',
		}
	},
	-- {
	-- 	'milanglacier/minuet-ai.nvim',
	-- 	config = function()
	-- 		require('minuet').setup {
	-- 			provider = 'openai_fim_compatible',
	-- 			n_completions = 1,
	-- 			context_window = 512,
	-- 			provider_options = {
	-- 				openai_fim_compatible = {
	-- 					api_key = 'TERM',
	-- 					name = 'Ollama',
	-- 					end_point = 'http://localhost:11434/v1/chat/completions',
	-- 					model = 'deepseek-r1:7b',
	-- 					optional = {
	-- 						max_tokens = 256,
	-- 						stop = { '\n\n' },
	-- 						top_p = 0.9,
	-- 					},
	-- 				},
	-- 			},
	-- 		}
	-- 	end,
	-- },
	{
		"xzbdmw/colorful-menu.nvim",
	},
	{
		'saghen/blink.cmp',
		dependencies = {
			{ 'disrupted/blink-cmp-conventional-commits' },
		},
		version = '1.*',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = 'enter' },
			completion = {
				menu = {
					scrollbar = false,
					border = 'rounded',
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
					draw = {
						columns = { { "kind_icon" }, { "label", gap = 1 } },
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
						},
					},
				},
				documentation = { auto_show = true, window = { border = 'rounded' } },
			},
			signature = { enabled = true, window = { border = 'rounded' } },
			sources = {
				default = { 'conventional_commits', 'lsp', 'path', 'buffer' },
				providers = {
					conventional_commits = {
						name = 'Conventional Commits',
						module = 'blink-cmp-conventional-commits',
						enabled = function()
							return vim.bo.filetype == 'gitcommit'
						end,
						---@module 'blink-cmp-conventional-commits'
						---@type blink-cmp-conventional-commits.Options
						opts = {},
					},
				},
			},
			fuzzy = { implementation = "prefer_rust_with_warning" }
		},
		opts_extend = { "sources.default" }
	},
	{
		'mrcjkb/rustaceanvim', -- Rust-specific tooling
		version = '^6',
		lazy = false,    -- this plugin is already lazy
		config = function()
			vim.g.rustaceanvim = {
				tools = {
					enable_clippy = true,
					enable_nextest = true,
					float_win_config = {
						auto_focus = true,
						open_split = "horizontal",
					},
				},
			}
		end,
	},
	{
		'saecki/crates.nvim', -- better support for editing Cargo.toml
		tag = 'stable',
		lazy = true,
		ft = { 'rust', 'toml' },
		event = { 'BufRead', 'BufReadPre', 'BufNewFile' },
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require('crates').setup {
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
				popup = {
					border = 'rounded',
				},
			}
		end,
	},
	{
		'j-hui/fidget.nvim', -- progress indicator UI (bottom right)
		tag = 'legacy',
		event = 'LspAttach',
		opts = {
			text = {
				spinner = 'dots',
				done = '✓',
			}
		},
	},
	-- { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
	{
		'Everblush/nvim', -- colorscheme
		name = 'everblush',
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd('colorscheme everblush')
		end
	},
	{
		'folke/trouble.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			auto_preview = true,
			use_diagnostic_signs = true,
		},
	},
	{
		'folke/todo-comments.nvim', -- highlighting for todo/fixme/perf/bug comment
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = {
			highlight = {
				pattern = [[.*<(KEYWORDS)\s*(\(\@?\w*\))?\s*:?]],
			},
		},
	},
	'Darazaki/indent-o-matic',           -- indentation style detection
	{
		'lukas-reineke/indent-blankline.nvim', -- indent line
		main = 'ibl',                    -- select version 3
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
		'terrortylor/nvim-comment', -- simple comment toggling
		init = function()
			require('nvim_comment').setup()
		end,
	},
	'rvmelkonian/move.vim', -- support for Move smart contract language
	{
		'tpope/vim-fugitive', -- git tooling
		dependencies = {
			'tpope/vim-rhubarb', -- add GitHub support
		},
	},
	'lewis6991/gitsigns.nvim', -- git status indicators for lines
	{
		'sindrets/diffview.nvim',
		event = 'VeryLazy',
		cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
	},
	'nvim-lualine/lualine.nvim', -- fancy status line
	'nvim-treesitter/nvim-treesitter',
	'mbbill/undotree',        -- undo history UI
	{
		'theprimeagen/harpoon',
		config = function()
			local mark = require('harpoon.mark')
			local ui = require('harpoon.ui')
			vim.keymap.set('n', '<leader>a', mark.add_file)
			vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)
			vim.keymap.set('n', '<C-h>', function() ui.nav_file(1) end)
			vim.keymap.set('n', '<C-t>', function() ui.nav_file(2) end)
			vim.keymap.set('n', '<C-n>', function() ui.nav_file(3) end)
			vim.keymap.set('n', '<C-s>', function() ui.nav_file(4) end)
		end,
	},
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.9',
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
		'Exafunction/codeium.nvim', -- LLM-based code completion
		event = 'BufEnter',
	},
	-- {
	-- 	'huggingface/llm.nvim',
	-- 	opts = {
	-- 		backend = "ollama",
	-- 		model = "deepseek-r1:1.5b",
	-- 		url = "http://localhost:11434", -- llm-ls uses "/api/generate"
	-- 		-- cf https://github.com/ollama/ollama/blob/main/docs/api.md#parameters
	-- 		request_body = {
	-- 			-- Modelfile options for the model you use
	-- 			options = {
	-- 				temperature = 0.2,
	-- 				top_p = 0.95,
	-- 			}
	-- 		}
	-- 	}
	-- },
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false,
		opts = {
			provider = "ollama",
			providers = {
				ollama = {
					endpoint = "http://localhost:11434",
					model = "qwq:latest",
				},
			},
		},
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"hrsh7th/nvim-cmp",   -- autocompletion for avante commands and mentions
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	-- {
	-- 	'olimorris/codecompanion.nvim',
	-- 	dependencies = {
	-- 		'nvim-lua/plenary.nvim',
	-- 		'nvim-treesitter/nvim-treesitter',
	-- 	},
	-- 	config = true
	-- },
	{
		'nomnivore/ollama.nvim', -- ollama LLM integration
		dependencies = {
			'nvim-lua/plenary.nvim',
		},

		-- user commands added by the plugin
		cmd = { 'Ollama', 'OllamaModel', 'OllamaServe', 'OllamaServeStop' },

		keys = {
			-- Sample keybind for prompt menu. Note that the <c-u> is important for selections to work properly.
			{
				'<leader>oo',
				":<c-u>lua require('ollama').prompt()<cr>",
				desc = 'ollama prompt',
				mode = { 'n', 'v' },
			},

			-- Sample keybind for direct prompting. Note that the <c-u> is important for selections to work properly.
			{
				'<leader>oG',
				":<c-u>lua require('ollama').prompt('General')<cr>",
				desc = 'ollama Generate Code',
				mode = { 'n', 'v' },
			},
		},

		opts = {
			model = 'qwq',
			prompts = {
				General = {
					prompt = '$input',
					input_label = '> ',
					action = 'display',
				},
			}
		}
	},
	-- {
	-- 	'David-Kunz/gen.nvim',
	-- 	opts = {
	-- 		-- model = 'qwen2.5-coder:7b',
	-- 		model = 'llama3.1:70b',
	-- 	},
	-- },
})

-- -- CodeCompanion local LLM setup
-- require('codecompanion').setup({
-- 	adapters = {
-- 		ollama = function()
-- 			return require('codecompanion.adapters').extend('ollama', {
-- 				name = 'qwq:latest', -- Give this adapter a different name to differentiate it from the default ollama adapter
-- 				schema = {
-- 					model = {
-- 						default = 'qwq:latest',
-- 					},
-- 					num_ctx = {
-- 						default = 16384,
-- 					},
-- 					num_predict = {
-- 						default = -1,
-- 					},
-- 				},
-- 			})
-- 		end,
-- 	},
-- 	strategies = {
-- 		chat = {
-- 			adapter = "ollama",
-- 		},
-- 		inline = {
-- 			adapter = "ollama",
-- 		},
-- 		agent = {
-- 			adapter = "ollama",
-- 		},
-- 	},
-- })

-- require("gruvbox").setup({
-- 	palette_overrides = {
-- 		dark0 = "#121121",
-- 		dark1 = "#121121",
-- 	}
-- })
-- vim.cmd("colorscheme gruvbox")
-- require('gruvbox-material').setup({
-- 	italics = true, -- enable italics in general
-- 	contrast = 'hard',
-- })

-- LSP setup
local lsp = require('lsp-zero')
vim.opt.signcolumn = 'yes' -- avoid annoying layout shifts

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
	vim.lsp.handlers.hover,
	{ border = 'rounded' }
)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
	vim.lsp.handlers.signature_help,
	{ border = 'rounded' }
)

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

vim.lsp.config('lua_ls', lsp.nvim_lua_ls())

lsp.setup()

-- code completion setup
-- local cmp = require('cmp')
-- cmp.setup({
-- 	formatting = {
-- 		format = function(entry, vim_item)
-- 			if vim.tbl_contains({ 'path' }, entry.source.name) then
-- 				local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
-- 				if icon then
-- 					vim_item.kind = icon
-- 					vim_item.kind_hl_group = hl_group
-- 					return vim_item
-- 				end
-- 			end
-- 			return require('lspkind').cmp_format({ with_text = true })(entry, vim_item)
-- 		end,
-- 	},
-- 	mapping = cmp.mapping.preset.insert({
-- 		['<CR>'] = cmp.mapping.confirm({ select = false }),
-- 	}),
-- 	sources = {
-- 		{ name = 'codeium' },
-- 		{ name = 'nvim_lsp' },
-- 		{ name = 'path' },
-- 		{ name = 'buffer' },
-- 		{ name = 'treesitter' },
-- 		{ name = 'emoji' },
-- 		{ name = 'nerdfont' },
-- 	},
-- })

-- Codeium needs to be configured after `cmp` for the two to be compatible
require('codeium').setup({
	virtual_text = {
		enabled = true,

		-- These are the defaults

		-- Set to true if you never want completions to be shown automatically.
		manual = false,
		-- A mapping of filetype to true or false, to enable virtual text.
		filetypes = {},
		-- Whether to enable virtual text of not for filetypes not specifically listed above.
		default_filetype_enabled = true,
		-- How long to wait (in ms) before requesting completions after typing stops.
		idle_delay = 75,
		-- Priority of the virtual text. This usually ensures that the completions appear on top of
		-- other plugins that also add virtual text, such as LSP inlay hints, but can be modified if
		-- desired.
		virtual_text_priority = 65535,
		-- Set to false to disable all key bindings for managing completions.
		map_keys = true,
		-- The key to press when hitting the accept keybinding but no completion is showing.
		-- Defaults to \t normally or <c-n> when a popup is showing.
		accept_fallback = nil,
		-- Key bindings for managing completions in virtual text mode.
		key_bindings = {
			-- Accept the current completion.
			accept = "<Tab>",
			-- Accept the next word.
			accept_word = false,
			-- Accept the next line.
			accept_line = false,
			-- Clear the virtual text.
			clear = false,
			-- Cycle to the next completion.
			next = "<M-]>",
			-- Cycle to the previous completion.
			prev = "<M-[>",
		}
	}
})

vim.keymap.set('n', '<leader>gs', vim.cmd.Git)           -- open git status from fugitive
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle) -- toggle undo-tree

-- treesitter setup
require('nvim-treesitter.configs').setup {
	ensure_installed = {
		'bash', 'c', 'cpp', 'css', 'dockerfile', 'fish', 'go', 'haskell', 'html',
		'javascript', 'json', 'latex', 'lua', 'ocaml', 'python', 'rust', 'svelte',
		'toml', 'typescript', 'yaml', 'zig'
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

-- mason setup
require('mason').setup({})
require('mason-lspconfig').setup {
	ensure_installed = {
		'denols', 'docker_compose_language_service', 'dockerls', 'eslint', 'gopls',
		'lua_ls', 'move_analyzer', 'nil_ls', 'ocamllsp', 'ruff', 'solang', 'ts_ls',
		'zls'
	},
}

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
		lualine_b = {
			{
				'filename',
				symbols = { modified = '', readonly = '' }
			}
		},
		lualine_c = {
			{ 'branch', icon = '' },
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
					local clients = vim.lsp.get_clients()
					return (clients and clients[1].name) or ''
				end,
				icon = '',
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

-- minimalist vertical line style for git status of lines
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

local _border = "rounded"

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or _border
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.diagnostic.config {
	float = { border = _border },
	virtual_text = false,
	underline = false,
}
vim.api.nvim_set_keymap(
	'n', '<Leader>d', ':lua vim.diagnostic.open_float()<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	'n', '[d', ':lua vim.diagnostic.goto_prev({float={source=true}})<CR>',
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	'n', ']d', ':lua vim.diagnostic.goto_next({float={source=true}})<CR>',
	{ noremap = true, silent = true }
)
