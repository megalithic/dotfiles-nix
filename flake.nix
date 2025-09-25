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
  description = "🗿 megadotfiles (nix'd)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    mcp-hub.url = "github:ravitemer/mcp-hub";
    flake-parts.url = "github:hercules-ci/flake-parts";
    jujutsu.url = "github:martinvonz/jj";
    agenix.url = "github:ryantm/agenix";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    yazi.url = "github:sxyazi/yazi";
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nix-darwin
    , home-manager
    , neovim-nightly-overlay
    , mcp-hub
    , ...
    }@inputs:
    let
      username = "seth";
      system = "aarch64-darwin";
      arch = system;
      hostname = "megabookpro";
      version = "25.05";

      lib = nixpkgs.lib.extend (import ./lib/default.nix inputs);
      # inherit (lib) foldl recursiveUpdate mapAttrsToList;

      # pkgs = nixpkgs.legacyPackages.${system};
      overlays = [
        inputs.jujutsu.overlays.default

        # This overlay makes unstable packages available through pkgs.unstable
        (final: prev: rec {
          unstable = import nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
            config.allowUnfreePredicate = _: true;
          };
          ai-tools = inputs.nix-ai-tools.packages.${prev.system};

          # # gh CLI on stable has bugs.
          # inherit (nixpkgs-unstable.legacyPackages.${prev.system}) gh;

          mcphub = inputs.mcp-hub.packages."${prev.system}".default;
          # NOTE: here's how to do a custom neovim-nightly overlay:
          # REF: https://github.com/fredrikaverpil/dotfiles/blob/main/nix/shared/overlays/neovim.nix
          nvim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
          # karabiner-driverkit = prev.callPackage ./packages/karabiner-driverkit { };
          notmuch = prev.notmuch.override { withEmacs = false; };
        })
      ];


      mkInit =
        { system
        , script ? ''
            echo "no default app init script set."
          ''
        ,
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # REF: https://gist.github.com/monadplus/3a4eb505633f5b03ef093514cf8356a1
          init = pkgs.writeShellApplication {
            name = "init";
            text = script;
          };
        in
        {
          type = "app";
          program = "${init}/bin/init";
        };

      # inherit (self) outputs;
    in
    {
      inherit (self) outputs;

      # apps."x86_64-linux".default = mkInit { system = "x86_64-linux"; };
      # apps."aarch64-linux".default = mkInit { system = "aarch64-linux"; };
      apps."${arch}".default = mkInit {
        system = "${arch}";
        script = builtins.readFile scripts/${arch}_bootstrap.sh;
      };

      # Build darwin flake using:
      # darwin-rebuild switch --flake ~/nix
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem
        {
          inherit system lib;

          specialArgs = { inherit self inputs username system hostname version overlays; };
          modules = [
            { system.configurationRevision = self.rev or self.dirtyRev or null; }

            { nixpkgs.overlays = overlays; }
            { nixpkgs.config.allowUnfree = true; }

            ./hosts/${hostname}.nix
            ./modules/shared/darwin/system.nix

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./users/${username}/home.nix;
                extraSpecialArgs = { inherit inputs username system hostname version overlays; };
              };
            }

            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                # Install Homebrew under the default prefix
                enable = true;
                # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                enableRosetta = true;
                # User owning the Homebrew prefix
                user = username;
                autoMigrate = true;
                # Optional: Declarative tap management
                taps = {
                  "homebrew/homebrew-core" = inputs.homebrew-core;
                  "homebrew/homebrew-cask" = inputs.homebrew-cask;
                  "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                };
                # Optional: Enable fully-declarative tap management
                # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                mutableTaps = false;
              };
            }
          ];
        };
    };
}
