# desktop — Linux workstation (NixOS + home-manager + sway).
#
# Assembles the NixOS baseline + desktop module + overlays + home-manager.
# Hardware specifics (bootloader, fileSystems, disk layout, NIC) need to be
# replaced before this host can build — see the TODO block below.
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
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos.nix
    ../../modules/desktop
    ../../modules/overlays.nix
  ];

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  time.timeZone = lib.mkDefault "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- TODO: hardware-specific, replace on first deploy --------------------
  # nixos-anywhere / nixos-generate-config will emit real values for these.
  # Placeholders below are only enough to make `nix flake check` evaluate.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };
  # -------------------------------------------------------------------------

  # home-manager — same shape as the darwin host.
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.extraSpecialArgs = { inherit inputs vars; };
  home-manager.users.${vars.username}.imports = [
    ../../home
    ../../home/profiles/workstation.nix
  ];
}
