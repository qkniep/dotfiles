# Shared home-manager configuration (cross-platform core).
#
# Hybrid dotfile management:
#   - Out-of-store symlinks (edits to the repo apply immediately, no rebuild):
#       nvim   — whole dir; `:Lazy update` writes lazy-lock.json back to the repo.
#       fish   — config.fish only (fish_variables etc. stay machine-local).
#       claude — settings.json per profile only (state/secrets stay untracked).
#   - Store-managed (copied into the nix store; reproducible, rebuild to change):
#       ghostty, tmux, git — stable configs that rarely change.
#
# Out-of-store links use a runtime path (~/dotfiles/...); store-managed sources
# use flake-relative paths (../...), so those files must be git-tracked.
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  # Node-independent baseline package set (cross-platform CLI tooling).
  imports = [ ./packages.nix ];

  # Standalone home-manager needs these set explicitly. The nix-darwin and
  # NixOS HM integrations derive them from users.users.<name>, so mkDefault
  # keeps those paths winning when the module system layer is present.
  home.username = lib.mkDefault vars.username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${vars.username}" else "/home/${vars.username}"
  );

  home.stateVersion = "25.11";
  xdg.enable = true;

  # --- Out-of-store (live edits) --------------------------------------------
  xdg.configFile."nvim".source = link "configs/nvim";
  xdg.configFile."fish/config.fish".source = link "configs/fish/config.fish";

  # Claude Code: only settings.json per profile (theme, effortLevel,
  # enabledPlugins). Everything else in these dirs is machine state/secrets
  # (.claude.json holds oauth) and stays untracked. Direct single-hop symlinks
  # (not mkOutOfStoreSymlink: its /nix/store intermediate hop makes Claude's
  # atomic settings writes fail with EROFS) so Claude's own writes (e.g.
  # toggling a plugin) flow back to the repo as git diffs.
  # Profiles are switched via CLAUDE_CONFIG_DIR (see fish/config.fish); plain
  # `claude` is aliased to the personal profile, so ~/.claude is unmanaged.
  home.activation.claudeSettingsLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p $HOME/.claude-anza $HOME/.claude-personal
    run ln -sfn ${dotfiles}/configs/claude/anza-settings.json $HOME/.claude-anza/settings.json
    run ln -sfn ${dotfiles}/configs/claude/personal-settings.json $HOME/.claude-personal/settings.json
  '';

  # User-level CLAUDE.md (memory), shared across both profiles.
  home.file.".claude-anza/CLAUDE.md".source = link "configs/claude/CLAUDE.md";
  home.file.".claude-personal/CLAUDE.md".source = link "configs/claude/CLAUDE.md";

  # --- Store-managed (reproducible) -----------------------------------------
  xdg.configFile."ghostty/config".source = ../configs/ghostty/config;
  xdg.configFile."tmux/tmux.conf".source = ../configs/tmux/tmux.conf;
  xdg.configFile."tmux/weather.sh" = {
    source = ../configs/tmux/weather.sh;
    executable = true;
  };
  home.file.".gitconfig".source = ../configs/git/gitconfig;
  home.file.".cargo/config.toml".source = ../configs/cargo/config.toml;
  home.file.".cargo/cargo-generate.toml".source = ../configs/cargo/cargo-generate.toml;

  # bat reads $XDG_CONFIG_HOME/bat/config (note: the repo file is bat.config).
  xdg.configFile."bat/config".source = ../configs/bat/bat.config;

  # aerospace (macOS tiling WM); also honours ~/.aerospace.toml, but XDG matches
  # the rest of this layout.
  xdg.configFile."aerospace/aerospace.toml".source = ../configs/aerospace/aerospace.toml;

  # opencode: Ollama-provider wiring + the custom review agent. Auth/state live
  # under ~/.local/share/opencode, so the read-only store links are safe.
  xdg.configFile."opencode/opencode.json".source = ../configs/opencode/opencode.json;
  xdg.configFile."opencode/tui.json".source = ../configs/opencode/tui.json;
  xdg.configFile."opencode/agent/review.md".source = ../configs/opencode/agent/review.md;
}
