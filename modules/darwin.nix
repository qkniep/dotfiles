# Shared darwin baseline — applies to every macOS host.
#
# Host-specific settings (hostName, computerName, networking DNS, the Dock's
# persistent-apps) live in hosts/<name>/default.nix, not here.
{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
{
  # Required for nix-darwin to work
  system.stateVersion = 1;

  system.primaryUser = vars.username;

  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "REWARD IF LOST: ${vars.email}";
    screencapture.location = "~/Pictures/Screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  # Keyboard mappings
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Enable fish shell as default
  programs.fish.enable = true;
  programs.zsh.interactiveShellInit = ''
    if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
    then
      exec fish -l
    fi
  '';

  users.users.${vars.username} = {
    name = vars.username;
    # home-manager's nix-darwin integration derives the user's
    # home.homeDirectory from this, so it must be set.
    home = "/Users/${vars.username}";
  };

  # GUI / macOS-only apps. Cross-platform CLI tooling lives in the
  # node-independent baseline at home/packages.nix instead.
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    aerospace # macOS tiling WM
    alacritty
    brave
    cool-retro-term
    discord
    ghostty-bin
    qbittorrent
    signal-desktop-bin
    slack
    spotify
    tor
    zoom-us
    # blender  # FIXME: blender-5.0.1 marked broken on aarch64-darwin in nixpkgs
    # goxel  # FIXME: not available on aarch64-darwin (unsupported platform in nixpkgs)
    # telegram-desktop  # FIXME: pulls ffmpeg-6.1.3 from source, which fails to link on aarch64-darwin (ld: malformed -compatibility_version)
    # whatsapp-for-mac  # FIXME: 2.25.22.79 download fails (upstream returns HTTP 500); pinned version no longer hosted
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.agave
    nerd-fonts.blex-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.commit-mono
    nerd-fonts.fira-code
    nerd-fonts.geist-mono
    nerd-fonts.hack
    nerd-fonts.inconsolata
    nerd-fonts.iosevka
    nerd-fonts.jetbrains-mono
    nerd-fonts.monaspace
    nerd-fonts.sauce-code-pro
  ];

  # Touch ID for sudo. `reattach` pulls in pam_reattach so it also works
  # inside tmux/screen (otherwise pam_tid can't reach the GUI session).
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  # --- Nix's own settings ---------------------------------------------------
  # Determinate Nix manages the daemon, so nix.enable = false.
  nix.enable = false;

  # Custom Determinate Nix settings written to /etc/nix/nix.custom.conf
  determinateNix.customSettings = {
    # Enables parallel evaluation (remove this setting or set the value to 1 to disable)
    eval-cores = 0;
    extra-experimental-features = [
      "build-time-fetch-tree" # Enables build-time flake inputs
      "parallel-eval" # Enables parallel evaluation
    ];
  };
}
