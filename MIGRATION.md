# Migration: unified Nix flake for all machines

Living tracker for consolidating these dotfiles into a single Nix flake usable
across macOS, Linux desktop, and Linux servers — reproducible, easy to bootstrap,
and publishable as a forkable public repo.

Update the checkboxes as work lands. `[x]` done · `[~]` in progress · `[ ]` todo.

## Goals

- One config, everywhere it's allowed.
- Reproducible builds + system updates without version incompatibilities.
- One-command bootstrap from this repo.
- Public, forkable, usable out-of-the-box (personal/secret bits isolated).

## Decisions

| Area | Choice |
| --- | --- |
| Topology | One flake; a **shared home-manager module** consumed two ways: full **NixOS** on machines we own, **standalone home-manager** on locked-down hosts |
| Dotfiles | **Hybrid** — store-managed for stable configs (git, tmux, ghostty, starship); out-of-store symlinks for `nvim` (writes `lazy-lock.json`) and `fish` (frequently tweaked) |
| Secrets | **agenix**, landed before the repo goes public |
| Forkability | single `vars.nix` personalization point; sensitive bits encrypted |
| Linux WM | **sway** (retire i3) |
| nixpkgs | stable **26.05**, shared by all hosts (pins via `flake.lock`); `nixpkgs-unstable` only to cherry-pick neovim |
| home-manager | pinned to `release-26.05` (must track stable nixpkgs) |

## Host inventory

| Host | OS now | Mechanism | Profile | Status |
| --- | --- | --- | --- | --- |
| `qk-macbook` | macOS | nix-darwin + home-manager | workstation | active (source of truth) |
| `desktop` | Linux | NixOS + home-manager (sway) | workstation | planned |
| `hetzner` | Ubuntu | standalone home-manager now → NixOS later | server | planned |
| `ionos` | Ubuntu | standalone home-manager now → NixOS later | server | planned |
| ETH workstations (`ws205`, `ws203`, `ws021`, `quizco`) | shared Linux | **out of scope for Nix** (cannot migrate); optional lightweight dotfile sync later | — | not a Nix target |
| `wsl` (Windows gaming PC) | NixOS on WSL2 | NixOS-WSL + home-manager | server | active |

## Target layout (end state)

```
dotfiles/
├── flake.nix              # inputs + output wiring (thin); lives at repo ROOT
├── flake.lock
├── vars.nix              # SINGLE personalization point
├── hosts/{qk-macbook,desktop,wsl,hetzner,ionos}/
├── modules/{darwin,nixos,desktop}/
├── home/                 # shared home-manager (wiring, packages, profiles)
│   └── profiles/{workstation,server}.nix
├── configs/              # all dotfile content, one dir per tool
│   └── {fish,git,nvim,tmux,ghostty,claude,opencode,…}/
└── secrets/{secrets.nix,*.age}
```

> Why the flake must move to the repo root (Phase 2): store-managed dotfiles
> (`./tmux.conf`, `./nvim`, …) must live *inside* the flake tree. The flake is
> currently in `nix/`, so configs one level up are invisible to it. Out-of-store
> symlinks (Phase 1) don't need this, which is why HM is introduced first.

---

## Phase 0 — Cleanup & safety

- [x] Add a real repo `.gitignore` (`.DS_Store`, `*.hm-bak`, `.direnv/`, …). Note: `.DS_Store`
      was never actually tracked (only caught by the global excludesfile, which isn't portable to a fork)
- [x] Retire i3 / X11-only configs: `i3config`, `xinitrc`, `dmenurc` (`git rm`; history preserved)
- [x] Secret scan: **no keys/tokens/credential files tracked.** Going-public exposures
      are only `ssh_config` (server IPs + ETH-internal hostnames) and scattered personal
      identifiers (email, `computerName`, login text) → handled in Phase 2 (`vars.nix`)
      and Phase 5 (agenix).

## Phase 1 — home-manager on the Mac (out-of-store dotfiles)  ← in progress

Lowest-risk foundation: introduce home-manager into the darwin flake, managing the
currently-symlinked dotfiles declaratively. Reproduces today's behavior exactly
(same symlink targets), proves the HM layer before multiplying hosts. No flake
relocation, no package moves yet.

- [x] Add `home-manager` input (`release-25.11`, `follows` nixpkgs)
- [x] Commit `nvim/lazy-lock.json` to the repo (pins plugin versions, like flake.lock)
- [x] `nix/home/default.nix` managing dotfiles as **out-of-store** symlinks:
      `nvim` + `ghostty` whole-dir; `fish/config.fish`, `tmux.conf`, `gitconfig` file-level
      (fish/tmux dirs hold machine-local/external state that stays uncommitted)
- [x] Wire `home-manager.darwinModules` into `qk-macbook`; set `backupFileExtension`
      (also: set `users.users.qkniep.home`, which HM derives `home.homeDirectory` from)
- [x] Validate: `nix flake check --no-build` + dry-run build — both pass
- [x] **Cutover (user runs — needs sudo):** move `~/.config/nvim` aside, then
      `sudo nix run nix-darwin -- switch --flake .#qk-macbook`. HM backs up other existing
      files as `*.hm-bak`. (see the cutover steps below / in chat)
- [x] Note: `starship.toml` intentionally not deployed (not active today)

## Phase 2 — Restructure + hybrid store-managed dotfiles  ← done (eval/dry-run validated)

- [x] Move `flake.nix`/`flake.lock` to repo root; re-point `~/.config/nix-darwin → ~/dotfiles`;
      update `update.sh`, add root `.envrc`, fix `Justfile` (`nixdir := "."`), README, CLAUDE.md
- [x] Split into `flake.nix` (thin) + `vars.nix` + `hosts/qk-macbook/` + `modules/{darwin,overlays}.nix`
      + `home/{default,packages}.nix` + `home/profiles/{workstation,server}.nix`
- [x] Introduce `vars.nix` (username, fullName, email); host-specifics (hostName, computerName,
      DNS, Dock) live in `hosts/qk-macbook/`; login text now built from `vars.email`
- [x] **Node-independent baseline packages → `home/packages.nix`** (`home.packages`, installed on
      every host). GUI/macOS-only apps stay in `modules/darwin.nix`
- [x] Convert `git`, `tmux`, `ghostty` to store-managed; keep `nvim`/`fish` out-of-store
      (`nvim` whole-dir so `:Lazy update` writes `lazy-lock.json` back to the repo).
      `starship` skipped — not currently deployed (`starship init` commented out in fish)
- [x] **Cutover (user runs — needs sudo):** `sudo nix run nix-darwin -- switch --flake .#qk-macbook`
      to apply the restructure + store-managed configs (HM already owns these files, so it's a
      clean in-place update — no `*.hm-bak` collisions expected)

## Phase 3 — First Linux targets  ← scaffolded (eval-clean; deploy pending)

- [x] `homeConfigurations."${vars.username}@hetzner"` + `"${vars.username}@ionos"` (standalone HM,
      `server` profile, `x86_64-linux`). Both evaluate via `nix flake check --all-systems`. New
      `mkHome` helper in `flake.nix` constructs its own `pkgs` (with the `unstable` overlay) since
      standalone HM has no module-system layer to apply overlays for it
- [x] `home/` cross-platform: `home/default.nix` now sets `home.username` / `home.homeDirectory`
      defaults (mkDefault so darwin/NixOS HM integration still wins); `fish/config.fish`
      `system-update` branches Darwin / NixOS / apt-fallback and the `claude-*` aliases use `$HOME`
      + PATH lookup. `home/packages.nix` is pure cross-platform CLI tooling already — no `lib.optionals`
      guards needed yet; the convention (header note) is in place for when something surfaces
- [x] `nixosConfigurations.desktop` scaffolded (`hosts/desktop/`, `modules/nixos.nix`,
      `modules/desktop/` for sway + swaylock + swaybg + wl-clipboard + grim/slurp + gammastep +
      i3status-rust + fuzzel + dunst + greetd/tuigreet + pipewire). Evaluates with placeholder
      `boot.loader` / `fileSystems` — **before first build**, replace those with the output of
      `nixos-generate-config` (or let `nixos-anywhere` + `disko` write them)

## Phase 4 — Servers to NixOS (later) + WSL (optional)

- [ ] Migrate `hetzner`/`ionos` Ubuntu → NixOS via `nixos-anywhere` + `disko` (⚠️ destructive — back up first)
- [x] WSL via NixOS-WSL — `hosts/wsl/` (Windows gaming PC): NixOS baseline + shared HM with
      the `server` profile (no compositor under WSL2)

## Phase 5 — Secrets (agenix) — before going public

- [ ] Add `agenix`; recipients = host SSH keys + personal age key
- [ ] Encrypt `ssh_config` (server IPs + ETH hostnames) and any tokens
- [ ] Document re-keying so forkers substitute their own keys

## Phase 6 — CI, bootstrap, docs → public

- [ ] CI matrix builds every host (`darwinConfigurations.*.system`,
      `nixosConfigurations.*.config.system.build.toplevel`, `homeConfigurations.*.activationPackage`)
- [ ] Add FlakeHub Cache (Determinate-native) so CI doesn't rebuild the world
- [ ] Replace weekly `nix flake update` cron with `update-flake-lock` PR (CI builds all hosts before merge)
- [ ] Rewrite README bootstrap (Mac / NixOS / standalone HM one-liners)
- [x] Delete `bootstrap.sh`, `setup/`, `utility.sh`; update `CLAUDE.md`/`README`/`Justfile`
      (Linux-only package inventory snapshotted to the appendix below)
- [ ] Final secret audit → flip repo public

## Open items

- ETH workstation Nix access — confirmed out of scope (no migration).
- Server migration window for `nixos-anywhere` (destructive) — TBD.
- `lazy-lock.json` → **decided: commit it** (reproducible plugin pins; nvim linked whole-dir
  so `:Lazy update` writes the lockfile back to the repo).

## Appendix — Linux package snapshot (from retired `setup/pacman.sh`)

Inventory of what the old Arch installer set up that isn't covered by `home/packages.nix`
today. Use this as a checklist when fleshing out `hosts/desktop/`, `modules/desktop/`, and
the `workstation` profile (Phase 3). Most of these are NixOS module options, not bare
packages — `programs.sway.enable`, `services.greetd.enable`, etc. — but the names below
are what the system used to run, so they're the closest thing to a spec.

**Sway desktop stack:** `sway`, `swaylock`, `swaybg`, `wl-clipboard`, `i3status-rust`,
`greetd` (+ `tuigreet`), `bemenu`/`fuzzel` (launchers), `dunst` (notifications), `imv`
(images), `mpv` (video), `grim` + `slurp` (screenshots), `gammastep` (night light),
`wallutils`/`azote` (wallpaper), `nemo` (file manager), `papirus-icon-theme`,
`breeze-obsidian-cursor-theme`, `ttf-nerd-fonts-symbols`.

**GUI apps not in `modules/darwin.nix`:** `firefox`, `bitwarden`, `thunderbird`, `okular`,
`obsidian`, `gimp`, `remarkable`, `spotify-tui`, `teams`, `zoom` (darwin has `zoom-us`).
`spotifyd` for headless playback. Already on the mac and presumably wanted on Linux too:
`brave`, `signal-desktop`, `slack`, `spotify`, `discord`.

**Audio:** `alsa-tools`, `libvorbis`, `opus`, `flac`, `wavpack`, `alac-git`. On NixOS use
`services.pipewire.*`; ALSA pulled in transitively.

**Linux-only system services:** Docker daemon (`virtualisation.docker.enable`, user added to
`docker` group), local DBs (`sqlite`, `redis`, `mariadb`, `postgresql`) — only re-enable
what's actually used.

**Language tooling not in `home/packages.nix`:** `pyright`, `pylint`, `virtualenv`,
`pipenv`; Go tooling (`gopls`, `goreleaser`, `sqlc`, `gosec`, `scc`, `staticcheck`,
`errcheck`, `golint`, `gocritic`); JS/TS (`deno`, `nodejs`/`npm`/`yarn`, `typescript`,
`prettier`, `eslint`, `stylelint`); Haskell (`ghc`, `cabal-install`,
`haskell-language-server`); LaTeX (`texlive-full`, `texlab`); `dockerfile-language-server`.

**Skip when porting:** `paru`/AUR (nixpkgs covers everything), `rustup` bootstrap dance
(already in `home/packages.nix`), the interactive `prompt_lang_install` flow (declarative
now), legacy package versions where the macOS side has moved on (e.g. `exa` → `eza`).
