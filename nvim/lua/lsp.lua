local rust_tools = require('rust-tools')
local lspconfig = require('lspconfig')
local treesitter = require('nvim-treesitter.configs')
local fidget = require('fidget')

vim.g.coq_settings = { auto_start = 'shut-up' }

require('coq_3p') {
	{ src = 'copilot', short_name = 'COP', tmp_accept_key = '<c-r>', accept_key = '<c-f>' }
}

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

vim.g.markdown_fenced_languages = {
	'shell',
	'ts=typescript',
}

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local on_attach = function(_, bufnr)
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set(
		'n',
		'<space>wl',
		function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end,
		bufopts
	)
	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local signs = { Error = ' ', Warn = ' ', Info = ' ', Hint = ' ' }
for type, icon in pairs(signs) do
	local hl = 'DiagnosticSign' .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	virtual_text = {
		prefix = '•',
	}
})

-- Set up the different LSP clients.
lspconfig.gopls.setup { on_attach = on_attach }
lspconfig.pyright.setup { on_attach = on_attach }
-- Don't configure Rust here, as it is configured by the `rust-tools` plugin.
-- lspconfig.rust_analyzer.setup{on_attach = on_attach}
lspconfig.tsserver.setup { on_attach = on_attach }
lspconfig.denols.setup { on_attach = on_attach }
-- FIX: sqls formatter currently breaks completely (removes comments, DDL not supported, ...)
--lspconfig.sqls.setup {
--	on_attach = on_attach,
--	settings = {
--		sqls = {
--			lowercaseKeywords = true,
--		},
--	},
--}
lspconfig.sumneko_lua.setup {
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT'
			},
			diagnostics = {
				globals = { 'vim' }
			},
			telemetry = {
				enable = false
			}
		}
	}
}
lspconfig.texlab.setup { on_attach = on_attach }
lspconfig.dockerls.setup { on_attach = on_attach }
lspconfig.hls.setup { on_attach = on_attach }

rust_tools.setup {
	tools = {
		inlay_hints = {
			only_current_line = true,
			highlight = 'Comment'
		}
	},
	server = {
		standalone = false,
		root_dir = lspconfig.util.root_pattern('Cargo.toml'),
		on_attach = function(_, bufnr)
			on_attach(_, bufnr)
			vim.keymap.set('n', '<C-space>', rust_tools.hover_actions.hover_actions, { buffer = bufnr })
			vim.keymap.set('n', '<Leader>a', rust_tools.code_action_group.code_action_group, { buffer = bufnr })
		end
	}
}

treesitter.setup {
	ensure_installed = {
		'rust',
		'go',
		'python',
		'typescript',
		'javascript',
		'html',
		'css',
		'markdown',
		'c',
		'cpp',
		'lua',
		'latex',
		'bibtex',
		'sql',
		'bash',
		'haskell',
		'solidity',
		'json',
		'yaml',
		'toml'
	},
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

fidget.setup {
	text = {
		spinner = 'dots',
		done = '✓'
	},
	timer = {
		spinner_rate = 250
	}
}
