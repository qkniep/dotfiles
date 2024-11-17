{
  description = "Quentin's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, spicetify-nix }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.age
          pkgs.alacritty
          pkgs.alacritty-theme
          # pkgs.blender
          pkgs.bandwhich
          pkgs.bat
          pkgs.bottom
          pkgs.cargo-audit
          pkgs.cargo-criterion
          pkgs.cargo-deny
          pkgs.cargo-edit
          pkgs.cargo-flamegraph
          pkgs.cargo-license
          pkgs.cargo-make
          pkgs.cargo-nextest
          pkgs.cargo-outdated
          pkgs.cargo-release
          pkgs.cargo-show-asm
          pkgs.cointop
          pkgs.deno
          pkgs.discord
          pkgs.docker
          pkgs.docker-compose
          pkgs.dog
          pkgs.dust
          pkgs.eza
          # pkgs.f3d
          pkgs.fastfetch
          pkgs.fd
          pkgs.fzf
          pkgs.ghc
          pkgs.ghidra
          pkgs.go
          # pkgs.goxel
          pkgs.gping
          pkgs.grc
          pkgs.hexyl
          pkgs.httpie
          pkgs.hyperfine
          pkgs.jq
          pkgs.mkalias
          pkgs.mpv
          pkgs.neovim
          pkgs.nodejs_23
          # pkgs.numbat
          pkgs.nushell
          pkgs.ocaml
          pkgs.ollama
          pkgs.onefetch
          pkgs.opam
          pkgs.pik
          pkgs.poetry
          pkgs.portal
          pkgs.postgresql
          pkgs.procs
          pkgs.protobuf
          pkgs.pueue
          pkgs.python312
          pkgs.radare2
          pkgs.rainfrog
          pkgs.ripgrep
          pkgs.rustscan
          pkgs.rustup
          pkgs.safe-rm
          pkgs.signal-desktop
          pkgs.sketchybar
          pkgs.slack
          # pkgs.spotify
          pkgs.stockfish
          pkgs.tealdeer
          pkgs.teams
          pkgs.telegram-desktop
          pkgs.terminal-notifier
          pkgs.tor
          pkgs.tree-sitter
          pkgs.tmux
          pkgs.tokei
          pkgs.tz
          pkgs.warp-terminal
          pkgs.wget
          pkgs.wireshark
          pkgs.yabai
          pkgs.yarn
          pkgs.youplot
          pkgs.yt-dlp
          pkgs.zellij
          # pkgs.zig
          pkgs.zoom-us
          pkgs.zoxide
          pkgs.fishPlugins.colored-man-pages
          pkgs.fishPlugins.done
          pkgs.fishPlugins.forgit
          pkgs.fishPlugins.grc
          pkgs.fishPlugins.puffer
          pkgs.fishPlugins.sponge
          pkgs.fishPlugins.tide
          pkgs.ocamlPackages.async
          pkgs.ocamlPackages.base
          pkgs.ocamlPackages.batteries
          pkgs.ocamlPackages.core
          pkgs.ocamlPackages.stdio
          pkgs.python312Packages.aiohttp
          pkgs.python312Packages.bokeh
          pkgs.python312Packages.django
          pkgs.python312Packages.flask
          pkgs.python312Packages.matplotlib
          pkgs.python312Packages.mypy
          pkgs.python312Packages.numpy
          pkgs.python312Packages.pandas
          pkgs.python312Packages.pip
          pkgs.python312Packages.plotly
          pkgs.python312Packages.pytorch
          pkgs.python312Packages.requests
          pkgs.python312Packages.scikit-learn
          pkgs.python312Packages.scipy
          pkgs.python312Packages.seaborn
          pkgs.python312Packages.urllib3
          pkgs.python312Packages.virtualenv
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
        ];
        casks = [
          "adobe-creative-cloud"
          "alfred"
          "brave-browser"
          "magicavoxel"
          "protonvpn"
          "readdle-spark"
          "whatsapp"
          "zen-browser"
        ];
        onActivation.cleanup = "zap";
      };

      fonts.packages =
        [
          (pkgs.nerdfonts.override { fonts = [ "Agave" "FiraCode" "Hack" "Inconsolata" "Iosevka" "JetBrainsMono" "Monaspace" ]; })
        ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

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

      system.defaults = {
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        screencapture.location = "~/Pictures/screenshots";
      };

      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;
      programs.zsh = {
        interactiveShellInit = ''
          if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
          then
            exec fish -l
          fi
        '';
      };

      imports = [
        # For NixOS
        inputs.spicetify-nix.nixosModules.default
      ];

      programs.spicetify =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
        in
        {
          enable = true;
          theme = spicePkgs.themes.ziro;
          # colorScheme = "coral";
        };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      security.pam.enableSudoTouchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "qkniep";
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."macbook".pkgs;
  };
}
