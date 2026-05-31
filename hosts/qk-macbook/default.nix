# qk-macbook — the primary macOS machine (source of truth).
#
# Assembles the shared darwin baseline + overlays + home-manager, and sets the
# host-specific bits (machine identity, DNS, Dock).
{
  config,
  pkgs,
  lib,
  inputs,
  vars,
  ...
}:
{
  imports = [
    inputs.determinate.darwinModules.default
    inputs.home-manager.darwinModules.home-manager
    ../../modules/darwin.nix
    ../../modules/overlays.nix
  ];

  # Networking: machine identity + pinned DNS resolvers.
  # knownNetworkServices gates which services get networking.dns applied
  # (must match `networksetup -listallnetworkservices`).
  networking.computerName = "Quentin's MacBook Pro";
  networking.hostName = "qk-macbook";
  networking.knownNetworkServices = [
    "Wi-Fi"
    "Thunderbolt Bridge"
  ];
  networking.dns = [
    "1.1.1.1"
    "8.8.8.8"
    "8.8.4.4"
    "2001:4860:4860::8888"
    "2001:4860:4860::8844"
  ];

  system.defaults.dock = {
    autohide = false;
    mru-spaces = false;

    # apps under "/Applications/Nix Apps/" are symlinks with ugly arrow
    # use full out-path instead to get the proper icons
    persistent-apps = [
      "${pkgs.ghostty-bin.outPath}/Applications/Ghostty.app"
      "/Applications/Brave Browser.app"
      "${pkgs.spotify.outPath}/Applications/Spotify.app"
      "/Applications/WhatsApp.app"
      "${pkgs.signal-desktop.outPath}/Applications/Signal.app"
      "/Applications/Spark Desktop.app"
      "${pkgs.discord.outPath}/Applications/Discord.app"
      "${pkgs.slack.outPath}/Applications/Slack.app"
      "${pkgs.zoom-us.outPath}/Applications/zoom.us.app"
      "/System/Applications/System Settings.app"
      "/System/Applications/Utilities/Activity Monitor.app"
      "/System/Applications/iPhone Mirroring.app"
      "/Applications/Claude.app"
    ];
  };

  # home-manager — manage user dotfiles declaratively.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # First switch backs up pre-existing files to `*.hm-bak` instead of failing.
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = { inherit vars; };
  # username + homeDirectory are derived from users.users.${vars.username}.
  home-manager.users.${vars.username}.imports = [
    ../../home
    ../../home/profiles/workstation.nix
  ];
}
