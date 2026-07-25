# Shared NixOS baseline — applies to every NixOS host.
#
# Host-specific settings (hostName, hardware-configuration, bootloader, disk
# layout, networking) live in hosts/<name>/default.nix, not here. Desktop /
# server overlays live in modules/desktop/, etc.
{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
{
  # Required for every NixOS host. Pin to the nixpkgs release we track.
  system.stateVersion = "25.11";

  # Use fish as the login shell; mirror the macOS shim so launching zsh
  # transparently execs into fish in interactive sessions.
  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
    then
      exec fish -l
    fi
  '';

  users.users.${vars.username} = {
    isNormalUser = true;
    home = "/home/${vars.username}";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
    ];
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    extra-substituters = [ "https://claude-code.cachix.org" ];
    extra-trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];
  };
}
