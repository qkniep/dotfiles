# Linux desktop module — sway + Wayland stack.
#
# Cross-host desktop baseline: WM, lockscreen, status bar, launcher,
# notifications, screenshots, media viewers, fonts. Host-specific bits
# (display config, kanshi profiles, machine-only apps) live in hosts/<name>/.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- Display server / WM --------------------------------------------------
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swaybg
      wl-clipboard
      grim
      slurp
      gammastep
      i3status-rust
      fuzzel
    ];
  };

  # Login manager: tuigreet at the tty, drops into sway.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  # Audio (pipewire), bluetooth. Notifications via dunst, spawned from the
  # WM autostart (NixOS has no `services.dunst` — that's a home-manager option).
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  hardware.bluetooth.enable = true;

  # GUI apps not WM-bound (image/video viewers, file manager) + notifications.
  environment.systemPackages = with pkgs; [
    dunst
    imv
    mpv
    nemo
    brave
    signal-desktop
    slack
    spotify
    discord
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    papirus-icon-theme
  ];

  # Wayland-friendly env hints for Electron, Firefox, etc.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
