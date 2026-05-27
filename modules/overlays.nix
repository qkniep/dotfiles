# nixpkgs overlays shared by every host.
#
# Exposes the unstable channel as `pkgs.unstable.<name>` so individual packages
# can be cherry-picked from unstable (e.g. neovim) while the rest of the system
# tracks stable nixpkgs.
{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev) system;
        config.allowUnfree = true;
      };
    })
  ];
}
