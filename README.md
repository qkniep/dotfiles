# My Dev Setup

<p>
	<img src="https://img.shields.io/badge/-macOS-000000?style=for-the-badge&logo=apple&logoColor=white">
	<img src="https://img.shields.io/badge/-Nix-5277C3?style=for-the-badge&logo=NixOS&logoColor=white">
	<img src="https://img.shields.io/badge/-Ghostty-1D1D1D?style=for-the-badge&logo=ghostty&logoColor=white">
	<img src="https://img.shields.io/badge/-Fish-800080?style=for-the-badge&logo=GNOME-Terminal&logoColor=white">
	<img src="https://img.shields.io/badge/-Neovim-57A143?style=for-the-badge&logo=Neovim&logoColor=white">
</p>

My development setup, used on **macOS** (primary) and Linux (NixOS desktop +
Ubuntu/NixOS servers — see [`MIGRATION.md`](MIGRATION.md)). Currently this repo is
under heavy development, anything can change at any time!

## How it's built

A single **Nix flake** at the repo root (nix-darwin + home-manager, on Determinate
Nix) declares the whole system: GUI/macOS apps and macOS defaults via nix-darwin, a
cross-platform CLI baseline and the dotfiles via home-manager. `~/.config/nix-darwin`
is a symlink to this repo, so edits are live.

This is **mid-migration** to one flake usable across macOS, a Linux desktop, and Linux
servers — see [`MIGRATION.md`](MIGRATION.md) for the plan and status. The Mac
(`qk-macbook`) is the only live host today; `nixosConfigurations.desktop` and the
standalone-HM `homeConfigurations."qkniep@{hetzner,ionos}"` are scaffolded and
eval-clean, but not yet deployed.

## Documentation

- [Migration plan](MIGRATION.md) — the unified-flake migration: decisions, host
  inventory, phased checklist.
- [`CLAUDE.md`](CLAUDE.md) — repo architecture and conventions (flake layout, where
  to add software, how dotfiles reach the system).
- [Neovim config](configs/nvim/README.md) — single-file `init.lua`, lazy.nvim, keymaps,
  plugins, LSP setup.

## Getting Started

If you decide to use this on your own system, I recommend you fork the repo.
This way you can use the setup with symlinks into the git directory
and are able to push changes to your own fork of the repository.

### macOS (nix-darwin)

The whole system is declared in [`flake.nix`](flake.nix) (+ `hosts/`, `modules/`,
`home/`). Apply it via the Justfile:

```shell
just switch   # rebuild & activate
just update   # bump flake.lock (run before `just switch` to pull upstream updates)
```

See [`CLAUDE.md`](CLAUDE.md) for the flake layout and where to add or remove software.

### Linux

Scaffolded, not yet deployed. The flake exposes:

- `nixosConfigurations.desktop` — NixOS + home-manager + sway. Before the first build,
  replace the placeholder `boot.loader` / `fileSystems` in `hosts/desktop/default.nix`
  with the output of `nixos-generate-config` (or let `nixos-anywhere` + `disko` write
  them), then `sudo nixos-rebuild switch --flake .#desktop`.
- `homeConfigurations."qkniep@hetzner"` and `"qkniep@ionos"` — standalone home-manager on
  the Ubuntu VPSes. Activate with `nix run home-manager/release-25.11 -- switch --flake .#qkniep@hetzner`.

See [`MIGRATION.md`](MIGRATION.md) for the broader plan and Phase 4+ (NixOS migration of
the servers via `nixos-anywhere`, agenix for secrets, CI matrix).

## Influenced By

Also check out the dotfiles of these awesome people:

- https://github.com/folke/dot
- https://github.com/jdhao/nvim-config
- https://github.com/donnemartin/dev-setup
- https://github.com/paulirish/dotfiles
- https://github.com/mathiasbynens/dotfiles
- https://github.com/skwp/dotfiles
- https://github.com/holman/dotfiles
- https://github.com/thoughtbot/dotfiles
- https://github.com/HynDuf7/dotfiles

## License

Released under the [MIT License](LICENSE).
