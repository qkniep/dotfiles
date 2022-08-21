return require('packer').startup(function(use)
	-- Plugin Manager
	use 'wbthomason/packer.nvim'

	-- Visual
	use 'nvim-lualine/lualine.nvim' -- bottom bar
	use { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' } -- top bar
	use { 'kyazdani42/nvim-web-devicons', as = 'devicons' } -- filetype icons
	use 'norcalli/nvim-colorizer.lua' -- highlight colors in CSS, HTML, JS, etc.
	use 'j-hui/fidget.nvim' -- progress UI for nvim-lspconfig
	use 'Yggdroot/indentLine' -- show indentation levels
	use { 'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim',
		config = function()
			require('todo-comments').setup()
		end
	} -- colored highlighting for TODO, FIX, PERF, etc.
	use 'folke/lsp-colors.nvim' -- fix LSP colors for legacy colorschemes (like srcery)

	require('colorizer').setup()

	-- Themes
	use { 'srcery-colors/srcery-vim', as = 'srcery' }
	use { 'ayu-theme/ayu-vim', as = 'ayu' }
	use { 'chriskempson/base16-vim', as = 'base16' }
	use 'folke/tokyonight.nvim'
	use 'sainnhe/gruvbox-material'
	use 'sainnhe/everforest'
	use 'sainnhe/edge'
	use 'sainnhe/sonokai'
	use 'ajmwagar/vim-deus'

	-- Language Tools
	use 'neovim/nvim-lspconfig'
	use {
		'nvim-treesitter/nvim-treesitter',
		run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
	}
	use 'sheerun/vim-polyglot'
	use 'fatih/vim-go'
	use 'simrat39/rust-tools.nvim'
	use 'github/copilot.vim'

	-- Autocomplete
	use { 'ms-jpq/coq_nvim', branch = 'coq' }
	use { 'ms-jpq/coq.artifacts', branch = 'artifacts' }
	use { 'ms-jpq/coq.thirdparty', branch = '3p' }

	-- Git
	use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
	use 'tpope/vim-fugitive'
	use 'airblade/vim-gitgutter'
	-- TODO: Maybe replace gitgutter with gitsigns.nvim?!

	require('neogit').setup()

	-- Utilities
	use 'nvim-lua/plenary.nvim'
	use { 'nvim-telescope/telescope.nvim', branch = '0.1.x' }
	use 'editorconfig/editorconfig-vim'
	use 'aperezdc/vim-template'
	use 'tpope/vim-surround'
end)
