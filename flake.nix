# REF: Some useful resources
#
# https://nix.dev/
# https://nixos.org/guides/nix-pills/
# https://nix-community.github.io/awesome-nix/
# https://serokell.io/blog/practical-nix-flakes
# https://zero-to-nix.com/
# https://wiki.nixos.org/wiki/Flakes
# https://rconybea.github.io/web/nix/nix-for-your-own-project.html

{
  description = "megadotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Master nixpkgs is used for really bleeding edge packages. Warning
    # that this is extremely unstable and shouldn't be relied on. Its
    # mostly for testing.
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs-update.url = "github:ryantm/nixpkgs-update";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-plist-manager.url = "github:sushydev/nix-plist-manager";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # weechat-scripts = {
    #   url = "github:weechat/scripts";
    #   flake = false;
    # };

    yazi = {
      url = "github:sxyazi/yazi";
    };

    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };

    yazi-glow = {
      url = "github:Reledia/glow.yazi";
      flake = false;
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emmylua-analyzer-rust = {
      url = "github:EmmyLuaLs/emmylua-analyzer-rust";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jujutsu.url = "github:martinvonz/jj";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };


  outputs =
    { self, nixpkgs, home-manager, nix-darwin, nixpkgs-update, agenix, ... } @ inputs:
    let
      overlays = [
        inputs.jujutsu.overlays.default

        # This overlay makes unstable packages available through pkgs.unstable
        (final: prev: rec {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          };
          ai-tools = inputs.nix-ai-tools.packages.${prev.system};

          # # gh CLI on stable has bugs.
          # inherit (unstable.legacyPackages.${prev.system}) gh;
          #
          # # Want the latest version of these
          # inherit (unstable.legacyPackages.${prev.system}) claude-code;

          karabiner-driverkit = prev.callPackage ./packages/karabiner-driverkit { };

          notmuch = prev.notmuch.override { withEmacs = false; };
        })
      ];

      # pkgs = nixpkgs.legacyPackages.${arch};

      # mkSystem = import ./lib/mkSystem.nix {
      #   inherit overlays nixpkgs inputs;
      # };

      mkInit =
        { system
        , script ? ''
            echo "no default app init script set."
          ''
        ,
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          init = pkgs.writeShellApplication {
            name = "init";
            text = script;
          };
        in
        {
          type = "app";
          program = "${init}/bin/init";
        };

      username = "seth";
      arch = "aarch64-darwin";
      hostname = "megabookpro";
      version = "25.05";

      machineConfig = ./machines/${hostname}.nix;
      userOSConfig = ./users/${username}/darwin.nix;
      userHMConfig = ./users/${username}/home.nix;
    in
    {
      # apps."x86_64-linux".default = mkInit { system = "x86_64-linux"; };
      # apps."aarch64-linux".default = mkInit { system = "aarch64-linux"; };
      apps."${arch}".default = mkInit {
        system = "${arch}";
        script = ''
          set -Eueo pipefail

          DOTFILES_DIR="$HOME/.dotfiles-nix"
          SUDO_USER=$(whoami)
          FLAKE=$(hostname -s)

          if ! command -v xcode-select >/dev/null 2>&1
          then
            echo "installing xcode.."
            xcode-select --install
            sudo -u "$SUDO_USER" softwareupdate --install-rosetta --agree-to-license
            # sudo -u "$SUDO_USER" xcodebuild -license
          fi

          if [ ! -d "$DOTFILES_DIR" ]; then
            echo "cloning dotfiles to $DOTFILES_DIR.."
            git clone https://github.com/megalithic/dotfiles-nix "$DOTFILES_DIR"
          fi

          if ! command -v brew >/dev/null 2>&1
          then
            echo "installing homebrew.."
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi

          echo "running nix-darwin for the first time.."
          # sudo nix --experimental-features 'nix-command flakes' run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake "$DOTFILES_DIR#$FLAKE"
          sudo nix --experimental-features 'nix-command flakes' run nix-darwin -- switch --flake "$DOTFILES_DIR#$FLAKE"

          echo "running home-manager for the first time.."
          sudo nix --experimental-features 'nix-command flakes' run home-manager/master -- switch --flake "$DOTFILES_DIR#$FLAKE"

          # nix run nix-darwin -- switch --flake "$DOTFILES_DIR"
          # nix run home-manager/master -- switch --flake "$DOTFILES_DIR"
        '';
      };

      # darwinConfigurations.megabookpro = mkSystem "megabookpro" {
      #   system = "aarch64-darwin";
      #   user = "seth";
      #   darwin = true;
      #   version = "25.05";
      # };

      darwinConfigurations.megabookpro = inputs.nix-darwin.lib.darwinSystem {
        system = "${arch}";
        specialArgs = {
          inherit self;
          inherit inputs;
          inherit overlays;
          inherit username;
          inherit arch;
          inherit hostname;
          inherit version;
        };
        modules = [
          {
            nixpkgs = {
              # Allow unfree packages.
              config.allowUnfree = true;
              hostPlatform = "${arch}";
              inherit overlays;
            };
          }
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
          machineConfig
          userOSConfig
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import userHMConfig {
              inherit self;
              inherit inputs;
              inherit overlays;
              inherit username;
              inherit arch;
              inherit hostname;
              inherit version;
            };
            home-manager.backupFileExtension = "backup";
          }
          # # We expose some extra arguments so that our modules can parameterize
          # # better based on these values.
          # {
          #   config._module.args = {
          #     inherit inputs;
          #     inherit overlays;
          #     inherit username;
          #     inherit arch;
          #     inherit hostname;
          #     inherit version;
          #   };
          # }
        ];
      };
    };
}
