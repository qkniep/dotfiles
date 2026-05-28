# Justfile — checks, lints, and a nix dry-run build for these dotfiles.
# Run `just` (or `just --list`) to see all recipes.
#
# Linters are fetched on demand via `nix run nixpkgs#<tool>`, so nothing needs
# to be installed globally. The flake lives at the repo root; because it's a git
# repo, `git add` new files before building or nix silently ignores them
# (uncommitted edits still build, with a "dirty tree" warning).
#
# Policy: correctness checks gate CI (nix eval/build, luacheck, fish parse,
# nvim smoke test); formatting checks (stylua, nixfmt) are reported but
# non-blocking.

nixdir := "."

# List available recipes.
default:
	@just --list

# Run every blocking check (what CI gates on).
check: nix-check nix-build lint nvim-smoke

# --- Nix -------------------------------------------------------------------

# Evaluate the whole flake (catches eval errors) without building anything.
nix-check:
	cd {{nixdir}} && nix flake check --no-build

# Dry-run build of the macOS system: shows what *would* build, builds nothing.
nix-build:
	cd {{nixdir}} && nix build .#darwinConfigurations.qk-macbook.system --dry-run

# Bump flake inputs (writes flake.lock); run before `just switch` to pull updates.
update:
	cd {{nixdir}} && nix flake update

# Rebuild & activate the macOS system from the current flake.
switch:
	cd {{nixdir}} && sudo darwin-rebuild switch --flake .#qk-macbook

# --- Lints (blocking) ------------------------------------------------------

# Run all blocking lints.
lint: lint-lua lint-fish lint-editorconfig

# Lua static analysis (config in .luacheckrc).
lint-lua:
	nix run nixpkgs#lua54Packages.luacheck -- configs/nvim/init.lua

# Fish: parse-only syntax check.
lint-fish:
	nix run nixpkgs#fish -- --no-execute configs/fish/config.fish

# Universal whitespace / final-newline / line-ending checks.
lint-editorconfig:
	nix run nixpkgs#editorconfig-checker

# --- Formatting (non-blocking in CI) ---------------------------------------

# Report formatting drift without changing files.
fmt-check: fmt-check-lua fmt-check-nix

fmt-check-lua:
	nix run nixpkgs#stylua -- --check configs/nvim/

fmt-check-nix:
	cd {{nixdir}} && nix fmt -- --check flake.nix

# Apply formatters in place.
fmt: fmt-lua fmt-nix

fmt-lua:
	nix run nixpkgs#stylua -- configs/nvim/

fmt-nix:
	cd {{nixdir}} && nix fmt

# --- Neovim ----------------------------------------------------------------

# Mason/treesitter auto-installs run async and are tolerated; only real Lua
# errors fail. Needs `nvim` on PATH.
#
# Headless smoke test: install plugins on a throwaway profile, then load config.
nvim-smoke:
	#!/usr/bin/env bash
	set -euo pipefail
	root="$(pwd)"
	tmp="$(mktemp -d)"
	trap 'rm -rf "$tmp"' EXIT
	mkdir -p "$tmp/config" "$tmp/data" "$tmp/state" "$tmp/cache"
	# Copy (not symlink): lazy.nvim writes lazy-lock.json next to the config,
	# and a symlink would leak that file back into the repo's configs/nvim/ dir.
	cp -R "$root/configs/nvim" "$tmp/config/nvim"
	export XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data"
	export XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"
	log="$tmp/err.log"
	echo ">> installing plugins (lazy sync)…"
	nvim --headless "+Lazy! sync" +qa 2>"$log" || true
	echo ">> loading config…"
	nvim --headless +qa 2>>"$log" || true
	if [ -s "$log" ]; then echo "--- neovim stderr ---"; cat "$log"; fi
	if grep -qiE 'E[0-9]+:|stack traceback|Error executing' "$log"; then echo "::error::neovim reported Lua errors on startup"; exit 1; fi
	echo "neovim config loaded cleanly ✅"
