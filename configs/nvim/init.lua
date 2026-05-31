-- ===== Options =====
vim.keymap.set('n', ' ', '<Nop>', { silent = true, remap = false })
vim.g.mapleader = ' '

-- basic UI settings
vim.o.background = 'dark'
vim.o.termguicolors = true
vim.o.guicursor = ''
vim.o.number = true
vim.o.scrolloff = 4
vim.o.winborder = 'rounded' -- default border for all floats (incl. LSP hover / signature-help)

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

-- start with all folds open; treesitter foldexpr is wired up per-buffer below
vim.o.foldlevelstart = 99

-- ===== Keymaps =====
vim.keymap.set('n', '<leader><CR>', '<cmd>Cargo nextest run --all-targets<CR>')

vim.keymap.set('n', 'J', 'mzJ`z')        -- join current and following line
vim.keymap.set('n', '<Esc>', ':noh<CR>') -- reset search highlighting

-- move current selection around
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- yank into system register
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('v', '<leader>y', '"+y')

-- delete into void register
vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')

-- cycle through diagnostics (warnings/errors)
vim.keymap.set('n', '<C-k>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-j>', '<cmd>cprev<CR>zz')

-- cycle through location list
vim.keymap.set('n', '<leader>k', '<cmd>lprev<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lnext<CR>zz')

-- ===== Plugins =====
-- setup for Lazy plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
  -- completion & LSP
  'neovim/nvim-lspconfig',     -- bundled vim.lsp.config defaults per server
  {
    'williamboman/mason.nvim', -- installs LSP servers
    config = function()
      require('mason').setup({})
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim', -- installs + auto-enables them (vim.lsp.enable)
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'docker_compose_language_service',
          'dockerls',
          'eslint',
          'gopls',
          'lua_ls',
          'move_analyzer',
          'nil_ls',
          'ruff',
          'solang',
          'ts_ls',
          'zls',
        },
      })
    end,
  },
  {
    'saghen/blink.cmp',
    dependencies = {
      { 'disrupted/blink-cmp-conventional-commits' },
      'xzbdmw/colorful-menu.nvim', -- only used by blink's menu draw (below)
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
          winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
          draw = {
            columns = { { 'kind_icon' }, { 'label', gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  return require('colorful-menu').blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require('colorful-menu').blink_components_highlight(ctx)
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
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
  {
    'j-hui/fidget.nvim', -- progress indicator UI (bottom right)
    event = 'LspAttach',
    config = function()
      -- fidget right-aligns its text in a window 1 col wider than the content, so
      -- a blank column always sits on the left (it can't be removed via options).
      -- Dropping line_margin (below) kills the symmetric padding on both sides;
      -- pad the spinner frames on the right instead so each side has exactly 1 col.
      local dots = vim.tbl_map(function(f)
        return f .. ' '
      end, require('fidget.spinner.patterns').dots)

      require('fidget').setup({
        progress = {
          display = {
            -- LSP progress is many short-lived tasks; render_limit = 0 hides those
            -- per-task lines so only the group header shows: "<server> <spinner>".
            render_limit = 0,
            done_ttl = 0.5,                     -- clear quickly once the server is done
            progress_icon = { pattern = dots }, -- braille spinner next to the server name
            done_icon = '✓ ',
          },
        },
        notification = {
          view = {
            line_margin = 0,         -- no built-in side padding; see the icon padding above
            group_separator = false, -- no "--" between servers
          },
          window = {
            winblend = 0,              -- opaque box so it stands out from code (default 100 = see-through)
            border = 'rounded',
            normal_hl = 'NormalFloat', -- proper float bg instead of the dim Comment default
          },
        },
      })
    end,
  },

  -- languages
  {
    'mrcjkb/rustaceanvim', -- Rust-specific tooling
    version = '^7',
    lazy = false,          -- this plugin is already lazy
    config = function()
      vim.g.rustaceanvim = {
        tools = {
          enable_clippy = true,
          enable_nextest = true,
          float_win_config = {
            auto_focus = true,
            open_split = 'horizontal',
          },
        },
      }
    end,
  },
  {
    'nvim-neotest/neotest', -- test runner UI; failures show inline + in a panel
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      -- Rust support is rustaceanvim's built-in adapter (drives cargo nextest);
      -- no separate neotest-rust package needed.
      require('neotest').setup({
        adapters = { require('rustaceanvim.neotest') },
        icons = {
          failed = '✘',
          skipped = '',
          unknown = '',
          passed = '',
          running = '',
        },
      })
      -- neotest's default status colours are a brighter pink/cyan; link them to
      -- the diagnostic palette so test statuses match LSP diagnostics (failed=
      -- error, skipped=warn, unknown=info, passed=ok). Re-applied on :colorscheme,
      -- which clears highlight groups.
      local function status_hl()
        vim.api.nvim_set_hl(0, 'NeotestFailed', { link = 'DiagnosticError' })
        vim.api.nvim_set_hl(0, 'NeotestSkipped', { link = 'DiagnosticInfo' })
        vim.api.nvim_set_hl(0, 'NeotestUnknown', { link = 'DiagnosticWarn' })
        vim.api.nvim_set_hl(0, 'NeotestPassed', { link = 'DiagnosticOk' })
      end
      status_hl()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = status_hl })
    end,
    keys = {
      {
        '<leader>tt',
        function()
          require('neotest').run.run()
        end,
        desc = 'Test nearest',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand('%'))
        end,
        desc = 'Test file',
      },
      {
        '<leader>tl',
        function()
          require('neotest').run.run_last()
        end,
        desc = 'Test last',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Test summary panel',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open({ enter = true })
        end,
        desc = 'Test output',
      },
      {
        '<leader>tw',
        function()
          require('neotest').watch.toggle(vim.fn.expand('%'))
        end,
        desc = 'Test watch (file)',
      },
    },
  },
  {
    'saecki/crates.nvim',             -- better support for editing Cargo.toml
    tag = 'stable',
    event = { 'BufRead Cargo.toml' }, -- only plugin that touches Cargo.toml; nothing for .rs
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('crates').setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
        popup = {
          border = 'rounded',
        },
      })
    end,
  },
  'rvmelkonian/move.vim',                          -- support for Move smart contract language
  {
    'nvim-treesitter/nvim-treesitter-textobjects', -- structural text objects, motions, swaps
    branch = 'main',                               -- matches nvim-treesitter's main branch (new API)
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true }, -- jump forward to the next textobject if not on one
        move = { set_jumps = true },   -- record structural jumps in the jumplist (<C-o>/<C-i>)
      })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      -- SELECT (visual / operator-pending): a = around, i = inside.
      -- e.g. cif = change function body, daf = delete whole function, via = inside argument
      local objects = {
        af = '@function.outer',
        ['if'] = '@function.inner',
        ac = '@class.outer',
        ic = '@class.inner',
        aa = '@parameter.outer',
        ia = '@parameter.inner',
        al = '@loop.outer',
        il = '@loop.inner',
      }
      for lhs, obj in pairs(objects) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(obj, 'textobjects')
        end, { desc = 'Select ' .. obj })
      end

      -- MOTIONS (n/x/o, so d]f etc. works): ]f/[f function start, ]F/[F function end,
      -- ]]/[[ + ][/[] class start/end, ]a/[a next/prev argument. (]c/[c left to gitsigns.)
      local motions = {
        [']f'] = { move.goto_next_start, '@function.outer' },
        ['[f'] = { move.goto_previous_start, '@function.outer' },
        [']F'] = { move.goto_next_end, '@function.outer' },
        ['[F'] = { move.goto_previous_end, '@function.outer' },
        [']]'] = { move.goto_next_start, '@class.outer' },
        ['[['] = { move.goto_previous_start, '@class.outer' },
        [']['] = { move.goto_next_end, '@class.outer' },
        ['[]'] = { move.goto_previous_end, '@class.outer' },
        [']a'] = { move.goto_next_start, '@parameter.inner' },
        ['[a'] = { move.goto_previous_start, '@parameter.inner' },
      }
      for lhs, spec in pairs(motions) do
        vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
          spec[1](spec[2], 'textobjects')
        end, { desc = 'Goto ' .. spec[2] })
      end

      -- SWAP the argument under the cursor with the next / previous one
      vim.keymap.set('n', '<leader>sa', function()
        swap.swap_next('@parameter.inner')
      end, { desc = 'Swap next argument' })
      vim.keymap.set('n', '<leader>sA', function()
        swap.swap_previous('@parameter.inner')
      end, { desc = 'Swap previous argument' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- main branch API; no more .configs module/modules. install() is async
      -- and skips already-installed parsers, so it doubles as ensure_installed.
      require('nvim-treesitter').install({
        'bash',
        'caddy',
        'c',
        'comment', -- doc-comment injection chain: rust -> comment -> markdown -> markdown_inline
        'cpp',
        'css',
        'dockerfile',
        'fish',
        'go',
        'haskell',
        'html',
        'javascript',
        'json',
        'latex',
        'lua',
        'markdown',
        'markdown_inline',
        'ocaml',
        'python',
        'rust',
        'svelte',
        'toml',
        'typescript',
        'yaml',
        'zig',
      })

      -- highlighting + indentation are now Neovim-core features enabled per
      -- buffer. vim.treesitter.start resolves the language from the filetype
      -- (so sh->bash, tex->latex work) and errors when no parser is installed;
      -- pcall skips those.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end
        end,
      })
    end,
  },

  -- UI
  {
    'Everblush/nvim', -- colorscheme
    name = 'everblush',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme everblush')
    end,
  },
  {
    'nvim-lualine/lualine.nvim', -- fancy status line
    event = 'VeryLazy',
    config = function()
      require('lualine').setup({
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
              symbols = { modified = '', readonly = '' },
            },
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
                return clients[1] and clients[1].name or ''
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
      })
    end,
  },
  'Darazaki/indent-o-matic',               -- indentation style detection
  {
    'lukas-reineke/indent-blankline.nvim', -- indent line
    main = 'ibl',                          -- select version 3
    event = { 'BufReadPre', 'BufNewFile' },
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
    'folke/todo-comments.nvim', -- highlighting for todo/fixme/perf/bug comment
    dependencies = { 'nvim-lua/plenary.nvim' },
    event = 'VeryLazy',         -- keep highlighting on; keys/cmd below just add triggers
    cmd = { 'TodoTrouble', 'TodoLocList', 'TodoQuickFix' },
    keys = {
      {
        ']t',
        function()
          require('todo-comments').jump_next()
        end,
        desc = 'Next todo comment',
      },
      {
        '[t',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = 'Prev todo comment',
      },
      { '<leader>xt', '<cmd>TodoTrouble<cr>', desc = 'Todos (Trouble)' },
    },
    opts = {
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*(\(\@?\w*\))?\s*:?]],
      },
    },
  },
  {
    'folke/which-key.nvim', -- popup with available keybindings; flags overlaps
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      spec = {
        { '<leader>f', group = 'find' },    -- fff + snacks pickers
        { '<leader>x', group = 'trouble' }, -- diagnostics/quickfix lists
        { '<leader>g', group = 'git' },     -- fugitive status / diffview
        { '<leader>h', group = 'hunk' },    -- gitsigns
        { '<leader>s', group = 'swap' },    -- treesitter argument swap
        { '<leader>t', group = 'test' },    -- neotest runner
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer-local keymaps',
      },
    },
  },

  -- git
  {
    'tpope/vim-fugitive',  -- git tooling
    dependencies = {
      'tpope/vim-rhubarb', -- add GitHub support
    },
    cmd = { 'G', 'Git', 'Gdiffsplit', 'Gread', 'Gwrite', 'Gedit', 'GBrowse' },
    keys = {
      { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status' },
    },
  },
  {
    'kdheepak/lazygit.nvim', -- floating lazygit in nvim cwd
    cmd = { 'LazyGit', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'Lazygit' },
    },
  },
  {
    'lewis6991/gitsigns.nvim', -- git status indicators for lines
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      -- minimalist vertical line style for git status of lines
      local git_char = '┃'
      require('gitsigns').setup({
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
        on_attach = function(bufnr)
          local gs = require('gitsigns')
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          -- navigation (fall back to vim's ]c/[c when in a diff)
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gs.nav_hunk('next')
            end
          end, 'Next hunk')
          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gs.nav_hunk('prev')
            end
          end, 'Prev hunk')

          -- stage / reset
          map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
          map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
          map('v', '<leader>hs', function()
            gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'Stage hunk')
          map('v', '<leader>hr', function()
            gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'Reset hunk')
          map('n', '<leader>hS', gs.stage_buffer, 'Stage buffer')
          map('n', '<leader>hR', gs.reset_buffer, 'Reset buffer')

          -- inspect
          map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
          map('n', '<leader>hb', function()
            gs.blame_line({ full = true })
          end, 'Blame line')
          map('n', '<leader>hB', gs.toggle_current_line_blame, 'Toggle line blame')
          map('n', '<leader>hd', gs.diffthis, 'Diff this')
        end,
      })
    end,
  },
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewFileHistory',
    },
    keys = {
      {
        '<leader>gd',
        function()
          if next(require('diffview.lib').views) == nil then
            vim.cmd('DiffviewOpen')
          else
            vim.cmd('DiffviewClose')
          end
        end,
        desc = 'Diffview toggle',
      },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history (current file)' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>',   desc = 'File history (repo)' },
    },
  },

  -- navigation
  {
    'dmtrKovalenko/fff.nvim',                            -- frecency-ranked, typo-resistant file/grep picker (Rust core)
    build = function()
      require('fff.download').download_or_build_binary() -- prebuilt binary, cargo fallback
    end,
    opts = {
      prompt = '❯ ', -- override default '🪿 '
      layout = {
        prompt_position = 'top', -- match snacks' top input (fff default is bottom)
        -- mirror snacks' responsive switch: same 120-col threshold, and stack the
        -- preview below (like snacks' "vertical" preset) instead of fff's default top
        flex = { size = 120, wrap = 'bottom' },
      },
    },
    lazy = false, -- self-lazy: indexer warms in the background
    keys = {
      {
        '<C-p>',
        function()
          require('fff').find_files()
        end,
        desc = 'Find files (fff)',
      },
      {
        '<leader>ff',
        function()
          require('fff').find_files()
        end,
        desc = 'Find files (fff)',
      },
      {
        '<leader>fg',
        function()
          require('fff').live_grep()
        end,
        desc = 'Live grep (fff)',
      },
      {
        '<leader>fz',
        function()
          require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } })
        end,
        desc = 'Fuzzy grep (fff)',
      },
      {
        '<leader>fc',
        function()
          require('fff').live_grep({ query = vim.fn.expand('<cword>') })
        end,
        desc = 'Grep current word (fff)',
      },
    },
  },
  {
    'folke/snacks.nvim',
    -- scoped to the picker only; fff.nvim (above) owns files/grep
    opts = {
      picker = {
        enabled = true,
        prompt = '❯ ', -- match fff.nvim's prompt glyph
        layouts = {
          -- left-align titles to match fff (snacks centres them by default);
          -- indexed boxes deep-merge into snacks' built-in presets
          default = { layout = { [1] = { title_pos = 'left' }, [2] = { title_pos = 'left' } } },
          vertical = { layout = { title_pos = 'left', [3] = { title_pos = 'left' } } },
        },
      },
    },
    config = function(_, opts)
      require('snacks').setup(opts)
      -- match fff's colours: matches use IncSearch (snacks' Special is too faint)
      -- and the result count is grey (snacks' Totals=NonText reads red in this theme)
      local function picker_hl()
        vim.api.nvim_set_hl(0, 'SnacksPickerMatch', { link = 'IncSearch' })
        vim.api.nvim_set_hl(0, 'SnacksPickerTotals', { link = 'Comment' })
      end
      picker_hl()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = picker_hl })
    end,
    keys = {
      {
        '<leader>fb',
        function()
          -- sort by recency and drop the current buffer, so the top hit is the
          -- buffer you last came from (Enter switches straight back to it)
          require('snacks').picker.buffers({ sort_lastused = true, current = false })
        end,
        desc = 'Buffers (snacks)',
      },
      {
        '<leader>fh',
        function()
          require('snacks').picker.help()
        end,
        desc = 'Help tags (snacks)',
      },
      {
        '<leader>fd',
        function()
          require('snacks').picker.lsp_symbols()
        end,
        desc = 'Document symbols (snacks)',
      },
      {
        '<leader>fw',
        function()
          require('snacks').picker.lsp_workspace_symbols()
        end,
        desc = 'Workspace symbols (snacks)',
      },
      {
        '<leader>fe',
        function()
          require('snacks').picker.diagnostics()
        end,
        desc = 'Diagnostics (snacks)',
      },
      {
        '<leader>ft',
        function()
          require('snacks').picker.todo_comments()
        end,
        desc = 'Todo comments (snacks)',
      },
    },
  },
  {
    'theprimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('harpoon'):setup()
    end,
    keys = {
      {
        '<leader>a',
        function()
          require('harpoon'):list():add()
        end,
        desc = 'Harpoon add file',
      },
      {
        '<C-e>',
        function()
          local h = require('harpoon')
          h.ui:toggle_quick_menu(h:list())
        end,
        desc = 'Harpoon quick menu',
      },
      {
        '<C-h>',
        function()
          require('harpoon'):list():select(1)
        end,
        desc = 'Harpoon file 1',
      },
      {
        '<C-t>',
        function()
          require('harpoon'):list():select(2)
        end,
        desc = 'Harpoon file 2',
      },
      {
        '<C-n>',
        function()
          require('harpoon'):list():select(3)
        end,
        desc = 'Harpoon file 3',
      },
      {
        '<C-s>',
        function()
          require('harpoon'):list():select(4)
        end,
        desc = 'Harpoon file 4',
      },
    },
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer diagnostics (Trouble)',
      },
      { '<leader>xq', '<cmd>Trouble qflist toggle<cr>',      desc = 'Quickfix list (Trouble)' },
      { '<leader>xl', '<cmd>Trouble loclist toggle<cr>',     desc = 'Location list (Trouble)' },
    },
    opts = {
      auto_preview = true,
      use_diagnostic_signs = true,
    },
  },
  {
    'mbbill/undotree', -- undo history UI
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = 'Undotree toggle' },
    },
  },

  -- AI
  {
    'Exafunction/windsurf.nvim', -- LLM-based code completion
    event = 'InsertEnter',       -- virtual-text only, so nothing to do outside insert mode
    config = function()
      -- only values that differ from codeium.nvim's upstream defaults;
      -- everything else (idle_delay, keybindings, priority, …) is the default.
      require('codeium').setup({
        enable_cmp_source = false,         -- default true; using blink.cmp, not nvim-cmp
        virtual_text = { enabled = true }, -- default false
      })
    end,
  },
})

-- ===== LSP & diagnostics =====
-- LSP setup (native vim.lsp; mason-lspconfig below installs the servers and
-- auto-enables each with vim.lsp.enable, so there is no per-server setup here.
-- blink.cmp injects its completion capabilities into every server on its own.)
vim.opt.signcolumn = 'yes' -- avoid annoying layout shifts

-- ocaml-lsp is installed via opam, not mason, so enable it explicitly; its
-- cmd / filetypes / root markers come from nvim-lspconfig's bundled config.
vim.lsp.enable('ocamllsp')

-- teach lua_ls about the `vim` global and Neovim's runtime (for editing config)
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME, '${3rd}/luv/library' },
      },
      telemetry = { enable = false },
    },
  },
})

-- buffer-local keymaps + format-on-save, applied whenever a server attaches
-- (replaces lsp-zero's on_attach + default_keymaps). references and code-action
-- are also reachable via Neovim's native maps grr / gra.
local lsp_format = vim.api.nvim_create_augroup('lsp_format', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = function(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = bufnr })
    end

    map('K', vim.lsp.buf.hover)
    map('gs', vim.lsp.buf.signature_help)
    map('gd', vim.lsp.buf.definition)
    map('gD', vim.lsp.buf.declaration)
    map('gi', vim.lsp.buf.implementation)
    map('go', vim.lsp.buf.type_definition)
    map('<leader>rn', vim.lsp.buf.rename)
    map('<leader>ca', vim.lsp.buf.code_action)

    if client and client:supports_method('textDocument/formatting') then
      vim.api.nvim_clear_autocmds({ group = lsp_format, buffer = bufnr })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = lsp_format,
        buffer = bufnr,
        desc = 'Format buffer with LSP',
        callback = function()
          vim.lsp.buf.format({ async = false, bufnr = bufnr })
        end,
      })
    end
  end,
})

vim.diagnostic.config({
  virtual_text = false,
  underline = false,
  severity_sort = true,
  float = { source = 'if_many' },
  -- diagnostic sign icons (replaces lsp-zero's set_sign_icons)
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.HINT] = '⚑',
      [vim.diagnostic.severity.INFO] = '»',
    },
  },
})
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { silent = true })
-- cycle diagnostics; when Trouble is open, drive its selection so the list
-- stays in sync, otherwise fall back to native jump (identical to before)
local function diag_jump(dir, severity)
  return function()
    local trouble = require('trouble')
    -- Trouble nav can't filter by severity, so only drive it for the
    -- unfiltered ]d/[d; severity jumps always use the native jump.
    if trouble.is_open() and not severity then
      trouble[dir > 0 and 'next' or 'prev']({ skip_groups = true, jump = true })
    else
      vim.diagnostic.jump({ count = dir, severity = severity, float = true })
    end
  end
end
vim.keymap.set('n', '[d', diag_jump(-1), { silent = true })
vim.keymap.set('n', ']d', diag_jump(1), { silent = true })
vim.keymap.set('n', '[e', diag_jump(-1, vim.diagnostic.severity.ERROR), { silent = true })
vim.keymap.set('n', ']e', diag_jump(1, vim.diagnostic.severity.ERROR), { silent = true })
