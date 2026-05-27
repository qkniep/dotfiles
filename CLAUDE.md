# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles for Quentin Kniep's development environment, used on both macOS
(primary, current) and Arch/Manjaro Linux. There is no build or test step — changes
are validated by applying them and checking the resulting environment.

## Migration in progress — read `MIGRATION.md` first

This repo is mid-migration to a single Nix flake (nix-darwin + home-manager) usable
across macOS, a Linux desktop, and Linux servers. `MIGRATION.md` at the repo root is the
living plan + checklist; consult it before structural changes. Currently **only
`qk-macbook` (this Mac) is live**; the Linux hosts are scaffolded but not built yet.

## The flake (source of truth)

A single flake at the **repo root** (built on **Determinate Nix** — `nix.enable = false`,
daemon managed by Determinate; inputs from FlakeHub). Structure:

- **`flake.nix`** — thin: inputs + outputs wiring. Four helpers build hosts:
  `mkDarwin` (nix-darwin), `mkNixos` (NixOS), `mkHome` (standalone home-manager — constructs
  its own `pkgs` with the `unstable` overlay since there's no module-system to apply
  `modules/overlays.nix`), and `mkPkgs` underneath them. Outputs today:
  `darwinConfigurations.qk-macbook`, `nixosConfigurations.desktop`,
  `homeConfigurations."qkniep@{hetzner,ionos}"`. Also defines the devShell and `nix fmt` formatter.
- **`vars.nix`** — single point of personalization (username, fullName, email). Forkers
  edit this; almost nothing else references identity directly.
- **`hosts/<name>/`** — per-host config. `hosts/qk-macbook/default.nix` is the live source of
  truth (hostName, computerName, DNS, Dock `persistent-apps`) and wires up home-manager.
  `hosts/desktop/` scaffolds the NixOS workstation (sway) with **placeholder `boot.loader`
  / `fileSystems`** — replace those with real `nixos-generate-config` output before the first
  build. `hosts/{hetzner,ionos}/` are minimal HM stubs for the Ubuntu servers.
- **`modules/`** — `darwin.nix` is the shared darwin baseline (macOS `system.defaults`,
  keyboard remaps, Touch ID, zsh→fish shim, fonts, Determinate Nix settings, **GUI/macOS-only
  apps** in `environment.systemPackages`). `nixos.nix` is the parallel NixOS baseline
  (stateVersion, fish/zsh shim, normal-user definition). `desktop/` is the Wayland desktop
  overlay (sway + swaylock/swaybg/wl-clipboard, grim/slurp, fuzzel, dunst, greetd/tuigreet,
  pipewire). `overlays.nix` exposes `pkgs.unstable.*` to module-system hosts.
- **`home/`** — home-manager. `default.nix` manages dotfiles (hybrid; see below) and imports
  **`packages.nix`** — the **node-independent baseline** of cross-platform CLI tooling
  (`home.packages`), installed on every host. `home.username` / `home.homeDirectory` are
  derived from `vars.nix` via `mkDefault` so the standalone-HM path works while the
  darwin/NixOS HM integration still wins when present. `profiles/{workstation,server}.nix`
  are host-type overlays (stubs for now).

**Where to add software:** cross-platform CLI tools → `home/packages.nix`; GUI / macOS-only
apps → `modules/darwin.nix`. Commented-out entries carry `# FIXME:` notes — keep that
convention so it's obvious what to re-enable after a nixpkgs bump.

## Deployed nix config is symlinked from this repo

`~/.config/nix-darwin` is a **symlink to this repo root**, so editing the flake here is live
— there is no separate copy and no drift. `nix flake update` writes `flake.lock` straight
back into the repo.

**Nix only sees git-tracked files.** `git add` new files before building or they're silently
excluded from the flake; an uncommitted working tree still builds but prints a "Git tree is
dirty" warning. (The whole repo is now the flake, so this applies to every file the flake
references — `vars.nix`, `modules/`, `hosts/`, `home/`, and the store-managed configs.)

Apply nix changes via the Justfile recipes (split so input bumps are deliberate):

```shell
just switch   # rebuild & activate the current flake
just update   # bump flake.lock; run before `just switch` to pull upstream updates
```

The devShell also exposes `apply-nix-darwin-configuration` (`darwin-rebuild switch --flake
.`), and `.envrc` (`use flake`) loads it via direnv.

## How dotfiles reach the system

All dotfile content lives under **`configs/<tool>/`** (one dir per tool, mirroring the XDG
layout HM emits). They reach the system via **home-manager** (`home/default.nix`), not the
old symlink script. Hybrid strategy:

- **Out-of-store symlinks** (edits to the repo apply immediately, no rebuild):
  `configs/nvim` (whole dir — `:Lazy update` writes `lazy-lock.json` back into the repo)
  and `configs/fish/config.fish` (`fish_variables` etc. stay machine-local).
- **Store-managed** (copied into the nix store; rebuild to apply): `configs/ghostty`,
  `configs/tmux`, `configs/git` — stable configs.

Out-of-store sources use a runtime path (`~/dotfiles/configs/...`); store-managed sources
use flake-relative paths (`../configs/...`), so those files must be git-tracked.

## Key configs

- **`configs/fish/config.fish`** — primary interactive shell (zsh execs into fish via the
  nix config). Holds PATH additions, aliases (`vim`→nvim, `cat`→bat, `ls`→eza, `du`→dust,
  `top`→btm), vi keybindings, and the `claude-anza` / `claude-personal` aliases that switch
  `CLAUDE_CONFIG_DIR` between separate Claude Code profiles.
- **`configs/nvim/init.lua`** — single-file Neovim config, lazy.nvim plugin manager.
  `configs/nvim/` is symlinked whole into `~/.config/nvim`, so its `lazy-lock.json` is
  **committed to the repo** (pins plugin versions); `:Lazy update` rewrites it as a normal
  git diff. Heavily Rust-oriented: rustaceanvim, crates.nvim, blink.cmp completion,
  lsp-zero + mason for LSP. `<leader><CR>` runs `cargo nextest`.
- **`configs/opencode/`** — opencode AI config; `opencode.json` wires a local Ollama provider.
- **`configs/git/gitconfig`** — git aliases (`l`, `lg`, `s`, `d`, `amend`, `clean-branches`),
  `pull.rebase = true`, default branch `main`.

## Conventions

- Indentation in shell/config files is **tabs** (see `editorconfig`).
