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
  description = "🗿megadotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
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
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , neovim-nightly-overlay
    , mcp-hub
    , ...
    }@inputs:
    let
      username = "seth";
      system = "aarch64-darwin";
      hostname = "megabookpro";
      version = "25.11";
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


          mcphub = inputs.mcp-hub.packages."${prev.system}".default;
          nvim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
          karabiner-driverkit = prev.callPackage ./packages/karabiner-driverkit { };
          notmuch = prev.notmuch.override { withEmacs = false; };
        })
      ];

      inherit (self) outputs;
    in
    {
      # Build darwin flake using:
      # darwin-rebuild switch --flake ~/nix
      darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem
        {
          inherit system overlays;
          specialArgs = { inherit inputs username system hostname version overlays; };
          modules = [
            { nixpkgs.overlays = "${overlays}"; }

            ./systems/${hostname}/default.ex
            ./modules/shared/darwin/system.nix

            home-manager.darwinModules.home-manager
            {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username} = import ./users/${username};
              home-manager.extraSpecialArgs = { inherit inputs username system hostname version overlays; };
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
