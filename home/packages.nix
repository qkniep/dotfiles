# Node-independent baseline packages.
#
# Installed via home.packages on EVERY host (macOS, Linux desktop, and the
# standalone-home-manager Ubuntu servers — none of which share a system layer),
# so this is the single place for cross-platform CLI tooling. GUI / macOS-only
# apps do NOT belong here; they live in modules/darwin.nix (and later the
# workstation profile). When a Linux host needs a package guarded off, do it
# here with `lib.optionals`.
#
# A number of entries are commented out with `# FIXME:` notes explaining why
# (broken/unavailable in the current nixpkgs); keep that convention so it's
# obvious what to re-enable after a bump.
{ pkgs, lib, inputs, ... }:
{
  home.packages = with pkgs; [
    # --- shell / core CLI ---
    atuin # SQLite-backed shell history; rebinds Ctrl+R (init in fish/config.fish)
    bat
    bottom
    cointop
    dog
    dust
    eza
    fastfetch
    fd
    fzf
    gcc
    git
    grc
    hexyl
    jq
    onefetch
    openssl
    pdfgrep
    ripgrep
    safe-rm
    tealdeer
    tmux
    tz
    wget
    yazi # TUI file manager; `y` wrapper cds to last dir (fish/config.fish)
    youplot
    zellij
    zoxide

    # --- editor ---
    unstable.neovim # 0.12 from unstable; rest of system stays on stable

    # --- VCS / dev workflow ---
    act
    delta # syntax-highlighted git pager (core.pager in gitconfig; lazygit auto-detects)
    difftastic # structural/AST diff; on-demand via `git dft` / `git dlog` (not the default pager)
    gh
    gh-dash
    just
    jujutsu
    lazydocker
    lazygit
    tokei

    # --- build / compression / misc tooling ---
    age
    aria2
    autoconf
    cmake
    ffmpeg
    flamelens
    gnupatch
    hyperfine
    libwebp
    oha
    opentimestamps-client
    pik
    pkg-config
    protobuf
    stockfish
    tree-sitter
    xz
    zstd

    # --- containers ---
    docker
    docker-compose
    podman

    # --- language toolchains / runtimes ---
    bun
    elan
    gleam
    go
    nodejs_24
    nushell
    ocaml
    opam
    python313
    rustup
    zig
    # aider-chat  # FIXME: 0.86.1 checkPhase fails (3 tests, e.g. KeyError 'max_input_tokens'); re-enable after a nixpkgs bump
    # claude-code
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    ollama
    # opencode
    # weathr  # FIXME: no such package in nixpkgs (typo? closest match is `weather`)

    # --- rust helpers ---
    bacon # background `cargo check`/clippy/test watcher; run in a tmux pane
    cargo-criterion
    cargo-deny
    cargo-edit
    cargo-expand
    cargo-flamegraph
    cargo-fuzz
    cargo-geiger
    cargo-generate
    cargo-hack
    cargo-llvm-cov
    cargo-machete
    cargo-make
    cargo-msrv
    cargo-nextest
    cargo-outdated
    cargo-release
    cargo-show-asm
    cargo-spellcheck
    cargo-tarpaulin
    cargo-update
    cargo-vet
    sccache
    tokio-console

    # --- lua ---
    stylua
    editorconfig-checker

    # --- fish plugins ---
    fishPlugins.colored-man-pages
    fishPlugins.done
    # fishPlugins.fzf-fish  # FIXME: broken on both stable and unstable nixpkgs; re-enable after a bump. (Ctrl+R history, Ctrl+Alt+F files, Ctrl+Alt+L git log, etc.)
    fishPlugins.grc
    fishPlugins.puffer
    fishPlugins.sponge
    fishPlugins.tide

    # --- python data stack ---
    python313Packages.matplotlib
    python313Packages.numpy
    python313Packages.pandas
    python313Packages.requests
    python313Packages.scipy
    python313Packages.seaborn
    # python313Packages.torch
  ];
}
