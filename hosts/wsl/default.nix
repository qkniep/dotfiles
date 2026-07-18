# wsl — NixOS running under WSL2 on the Windows gaming PC.
#
# A full dev environment on the Windows side so switching to it doesn't mean
# leaving the Nix toolchain behind. Assembles the NixOS baseline + the shared
# home-manager config; no bootloader or fileSystems, since WSL supplies both.
#
# There is no Wayland compositor here, so modules/desktop is deliberately not
# imported — see the profile note below.
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
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos.nix
    ../../modules/overlays.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = vars.username;

  networking.hostName = "wsl";
  time.timeZone = lib.mkDefault "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # home-manager — same shape as the darwin and desktop hosts.
  #
  # Uses the *server* profile rather than workstation: those profiles split on
  # "has a GUI", and WSL has no compositor, so WM-adjacent config would be dead
  # weight here. Swap to workstation if that split ever becomes "interactive vs
  # headless" instead.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = { inherit inputs vars; };
  home-manager.users.${vars.username}.imports = [
    ../../home
    ../../home/profiles/server.nix
  ];
}
