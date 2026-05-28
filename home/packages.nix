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
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # --- shell / core CLI ---
    bat
    bottom
    cointop
    dog
    dust
    eza
    fastfetch
    fd
    fzf
    grc
    hexyl
    jq
    onefetch
    pdfgrep
    ripgrep
    safe-rm
    tealdeer
    tmux
    tz
    wget
    youplot
    zellij
    zoxide

    # --- editor ---
    unstable.neovim # 0.12 from unstable; rest of system stays on stable

    # --- VCS / dev workflow ---
    act
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
    oha
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
    # ollama  # FIXME: ollama 0.21.1 fails to build (patchPhase rm of removed test file); re-enable when nixpkgs is fixed
    # opencode
    # weathr  # FIXME: no such package in nixpkgs (typo? closest match is `weather`)

    # --- rust helpers ---
    cargo-audit
    cargo-criterion
    cargo-deny
    cargo-edit
    cargo-expand
    cargo-flamegraph
    cargo-fuzz
    cargo-generate
    cargo-hack
    cargo-license
    # cargo-llvm-cov  # FIXME: cargo-llvm-cov-0.6.20 marked broken in nixpkgs
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
    tokio-console

    # --- lua ---
    stylua
    editorconfig-checker

    # --- fish plugins ---
    fishPlugins.colored-man-pages
    fishPlugins.done
    fishPlugins.forgit
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
