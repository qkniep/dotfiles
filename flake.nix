{
  description = "Quentin Kniep's Nix configuration — nix-darwin + home-manager.";

  inputs = {
    # Stable nixpkgs (use 0.1 for unstable). Shared by every host. Pinned to the
    # current release (26.05) rather than floating `0` so it stays in lockstep
    # with nix-darwin / home-manager below; bump all three together.
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2605";
    # Unstable, used only to cherry-pick a few fast-moving packages (neovim).
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2605";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager pinned to the release branch matching the stable nixpkgs
    # above (currently 26.05); keep in lockstep on every nixpkgs bump.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NixOS under WSL2. Upstream ships `main` as the supported branch rather
    # than per-release ones, so this floats and is pinned via flake.lock.
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Code as a self-contained native binary, bumped hourly. Deliberately
    # no nixpkgs `follows`: the Cachix cache is keyed to this flake's own lock,
    # and overriding it would change drv hashes and force local rebuilds.
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    { self, ... }@inputs:
    let
      vars = import ./vars.nix;

      # Build a darwin host defined under hosts/<name>; pass inputs + vars to
      # every module via specialArgs.
      mkDarwin =
        system: hostModule:
        inputs.nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs vars; };
          modules = [ hostModule ];
        };

      # pkgs instance with the same `unstable` overlay nix-darwin gets via
      # modules/overlays.nix. Used by standalone home-manager outputs, which
      # construct their own pkgs (no module system to apply overlays).
      mkPkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            (final: prev: {
              unstable = import inputs.nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
            })
          ];
        };

      # Standalone home-manager host (Ubuntu servers today, pre-NixOS). Imports
      # the shared home/ + server profile + the per-host stub under hosts/<name>.
      mkHome =
        system: hostModule:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit inputs vars; };
          modules = [
            ./home
            ./home/profiles/server.nix
            hostModule
          ];
        };

      # NixOS host defined under hosts/<name>. The host module is responsible
      # for importing the NixOS baseline, overlays, and home-manager.
      mkNixos =
        system: hostModule:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs vars; };
          modules = [ hostModule ];
        };
    in
    {
      darwinConfigurations."qk-macbook" = mkDarwin "aarch64-darwin" ./hosts/qk-macbook;

      nixosConfigurations.desktop = mkNixos "x86_64-linux" ./hosts/desktop;
      nixosConfigurations.wsl = mkNixos "x86_64-linux" ./hosts/wsl;

      homeConfigurations."${vars.username}@hetzner" = mkHome "x86_64-linux" ./hosts/hetzner;
      homeConfigurations."${vars.username}@ionos" = mkHome "x86_64-linux" ./hosts/ionos;

      # Dev shell + formatter, run from the repo root (`nix develop`, `nix fmt`).
      devShells."aarch64-darwin".default =
        let
          system = "aarch64-darwin";
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = [
            (pkgs.writeShellApplication {
              name = "apply-nix-darwin-configuration";
              runtimeInputs = [ inputs.nix-darwin.packages.${system}.darwin-rebuild ];
              text = ''
                echo "> Applying nix-darwin configuration..."
                sudo darwin-rebuild switch --flake .
                echo "> macOS config applied 🚀"
              '';
            })
            self.formatter.${system}
          ];
        };

      # RFC 166 formatter. Format all files: `nix fmt`.
      formatter."aarch64-darwin" = inputs.nixpkgs.legacyPackages."aarch64-darwin".nixfmt-rfc-style;
    };
}
