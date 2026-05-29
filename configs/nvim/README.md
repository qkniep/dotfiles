# Neovim config

A single-file Neovim configuration ([`init.lua`](init.lua)), managed with the
[lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager. It is heavily
Rust-oriented but carries LSP/treesitter support for a broad set of languages.

- **Editor:** Neovim 0.12 (installed via the Nix flake's `unstable` overlay — see
  [`../nix/README.md`](../nix/README.md)). The config uses 0.11+ APIs throughout:
  native `vim.lsp.enable` / `vim.lsp.config`, the treesitter `main` branch API,
  and `vim.o`/`vim.opt`.
- **Plugin manager:** lazy.nvim, bootstrapped on first launch into
  `stdpath('data')/lazy/`. The lock file lives at
  `~/.config/nvim/lazy-lock.json` (not tracked in this repo).
- **Leader key:** `<Space>`.
- **Colorscheme:** [everblush](https://github.com/Everblush/nvim).

The whole config is one file by design; the sections below mirror its top-level
structure (`Options` → `Keymaps` → `Plugins` → `LSP & diagnostics`).

## Layout

`init.lua` is read top to bottom in four banners:

| Section            | What it sets up                                                            |
| ------------------ | ------------------------------------------------------------------------- |
| `Options`          | Core editor behavior (indent, search, folds, undo).                       |
| `Keymaps`          | Global, plugin-independent maps.                                          |
| `Plugins`          | The full `require('lazy').setup({ … })` spec.                             |
| `LSP & diagnostics`| Native LSP `on_attach`, `lua_ls`/`ocamllsp` config, diagnostic styling.   |

Most plugin-specific keymaps live inside each plugin's `keys`/`config` block
rather than in the global `Keymaps` section.

## Core options

- **Indentation:** 4-space tabs (`tabstop`/`softtabstop`/`shiftwidth = 4`),
  `smartindent`, `wrap = false`. `indent-o-matic` auto-detects per-file style.
- **Search:** `ignorecase` + `smartcase`; `<Esc>` clears highlight.
- **Persistence:** no swap/backup files; `undofile` on (persistent undo, browsable
  with undotree).
- **Folds:** start fully open (`foldlevelstart = 99`); treesitter `foldexpr` is
  wired up per-buffer.
- **UI:** relative-free `number`, `scrolloff = 4`, `termguicolors`, rounded
  borders for all floats (incl. LSP hover / signature help), block cursor in all
  modes (`guicursor = ''`).

## Keymaps

Leader is `<Space>`. Buffer-local maps (LSP, gitsigns) only apply where that
feature is active.

### Editing & movement

| Key                | Action                                          |
| ------------------ | ----------------------------------------------- |
| `J`                | Join line below, keep cursor in place           |
| `<Esc>`            | Clear search highlight                           |
| `J` / `K` (visual) | Move selection down / up (re-indent)            |
| `<leader>y`        | Yank to system clipboard (`"+`)                 |
| `<leader>d`        | Delete into the void register (`"_`)            |
| `<C-j>` / `<C-k>`  | Previous / next quickfix entry (centered)       |
| `<leader>j` / `<leader>k` | Next / previous location-list entry      |

### Finding (fff + snacks) — `<leader>f`

| Key          | Picker              |
| ------------ | ------------------- |
| `<C-p>`      | Git files           |
| `<leader>ff` | Find files          |
| `<leader>fg` | Live grep           |
| `<leader>fb` | Buffers             |
| `<leader>fh` | Help tags           |
| `<leader>fd` | Document symbols    |
| `<leader>fw` | Workspace symbols   |
| `<leader>fe` | Diagnostics         |
| `<leader>ft` | Todo comments       |

### LSP (buffer-local on attach)

| Key          | Action                                                  |
| ------------ | ------------------------------------------------------ |
| `K`          | Hover docs                                             |
| `gs`         | Signature help                                         |
| `gd` / `gD`  | Go to definition / declaration                        |
| `gi` / `go`  | Go to implementation / type definition                |
| `<leader>rn` | Rename symbol                                          |
| `<leader>ca` | Code action                                            |
| `grr` / `gra`| References / code action (Neovim native defaults)     |

Buffers are **formatted on save** automatically whenever the attached server
supports formatting (non-blocking — edits made while formatting is in flight are
discarded rather than clobbering the buffer).

### Diagnostics

| Key          | Action                                  |
| ------------ | --------------------------------------- |
| `<leader>e`  | Open diagnostic float                    |
| `[d` / `]d`  | Previous / next diagnostic               |
| `[e` / `]e`  | Previous / next **error**                |

`[d`/`]d` drive the Trouble list when it is open so the two stay in sync.

### Git

| Key                       | Action                                |
| ------------------------- | ------------------------------------- |
| `<leader>gs`              | Fugitive status                       |
| `<leader>gd`              | Diffview toggle                       |
| `<leader>gh` / `<leader>gH` | File history (current file / repo)  |
| `<leader>u`               | Undotree toggle                       |

Gitsigns hunk maps (`<leader>h`): `]c`/`[c` next/prev hunk, `hs`/`hr` stage/reset
hunk (also visual), `hS`/`hR` stage/reset buffer, `hp` preview, `hb` blame line,
`hB` toggle line blame, `hd` diff this.

### Trouble — `<leader>x`

`xx` diagnostics, `xX` buffer diagnostics, `xq` quickfix, `xl` location list,
`xt` todo comments.

### Harpoon

`<leader>a` add file, `<C-e>` quick menu, `<C-h>`/`<C-t>`/`<C-n>`/`<C-s>` jump to
files 1–4.

### Treesitter text objects & motions

Selections (`x`/`o`): `af`/`if` function, `ac`/`ic` class, `aa`/`ia` argument,
`al`/`il` loop. Motions: `]f`/`[f` & `]F`/`[F` function start/end, `]]`/`[[` &
`][`/`[]` class start/end, `]a`/`[a` argument. Swap argument under cursor with
`<leader>sa` (next) / `<leader>sA` (previous).

### Misc

- `<leader><CR>` — run `cargo nextest run --all-targets` via rustaceanvim.
- `<leader>?` — show buffer-local keymaps (which-key). which-key also labels the
  leader groups: `f` find, `x` trouble, `g` git, `h` hunk, `s` swap.
- `]t` / `[t` — jump to next / previous todo comment.

## Plugins

Grouped as in the spec:

**Completion & LSP**
- `nvim-lspconfig` — bundled per-server defaults (cmd, filetypes, root markers).
- `mason.nvim` + `mason-lspconfig.nvim` — install and auto-enable servers.
  `ensure_installed`: `docker_compose_language_service`, `dockerls`, `eslint`,
  `gopls`, `lua_ls`, `move_analyzer`, `nil_ls`, `ruff`, `solang`, `ts_ls`, `zls`.
- `blink.cmp` — completion (`enter` preset), with `colorful-menu.nvim` for the
  menu draw and `blink-cmp-conventional-commits` for commit messages.
- `fidget.nvim` — LSP progress UI (bottom right).

**Languages**
- `rustaceanvim` — Rust tooling (clippy + nextest enabled).
- `crates.nvim` — `Cargo.toml` editing (versions, completion, hover, actions).
- `move.vim` — Move smart-contract language support.
- `nvim-treesitter` (`main` branch) + `nvim-treesitter-textobjects`. Highlighting
  and indentation are enabled per buffer via `vim.treesitter.start`.

**UI**
- `everblush` colorscheme, `lualine.nvim` status line (everblush theme),
  `indent-o-matic` (style detection), `indent-blankline.nvim` (indent guides),
  `todo-comments.nvim`, `which-key.nvim`.

**Git**
- `vim-fugitive` (+ `vim-rhubarb` for GitHub), `gitsigns.nvim`, `diffview.nvim`.

**Navigation**
- `snacks.nvim` (picker), `harpoon` (harpoon2), `trouble.nvim`, `undotree`.

**AI**
- `windsurf.nvim` (Codeium) — virtual-text LLM completion, loaded on
  `InsertEnter`. (`nvim-cmp` source disabled since blink.cmp is the completion
  engine.)

## LSP notes

There is no per-server `setup()` — `mason-lspconfig` enables each installed server
with `vim.lsp.enable`, and `blink.cmp` injects completion capabilities. Two
exceptions are configured explicitly in the `LSP & diagnostics` section:

- **`ocamllsp`** — installed via `opam` (not Mason), so it is enabled by hand; its
  cmd/filetypes/root markers come from `nvim-lspconfig`.
- **`lua_ls`** — taught about the `vim` global and the Neovim runtime so editing
  this config is lint-clean.

## Maintaining the config

| Command         | Purpose                                                |
| --------------- | ------------------------------------------------------ |
| `:Lazy sync`    | Install/update/clean plugins to match the spec.        |
| `:Lazy update`  | Update plugins and refresh `lazy-lock.json`.           |
| `:Mason`        | Manage LSP servers / tools.                            |
| `:TSUpdate`     | Update treesitter parsers.                             |

From the repo root (recipes in [`../Justfile`](../Justfile)):

- `just lint-lua` — luacheck (config in [`../.luacheckrc`](../.luacheckrc)).
- `just fmt-lua` / `just fmt-check-lua` — stylua (config in
  [`../.stylua.toml`](../.stylua.toml)).
- `just nvim-smoke` — headless smoke test: sync plugins on a throwaway profile and
  load the config, failing on any Lua startup error. This is what CI gates on.
