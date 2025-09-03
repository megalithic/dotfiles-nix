{
  description = "megadotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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

    nh = {
      url = "github:nix-community/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      overlays = [
        # This overlay makes unstable packages available through pkgs.unstable
        (final: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          };

          inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system}) nh;
        })
      ];

      mkSystem = import ./lib/mksystem.nix {
        inherit overlays nixpkgs inputs;
      };
    in
    {
      # NOTE: for other systems when we get them:
      # nixosConfigurations.meganix = mkSystem "linux" {
      #   system = "x86_64-linux";
      #   user = "seth";
      # };
      darwinConfigurations.megabookpro = mkSystem "megabookpro" {
        system = "aarch64-darwin";
        user = "seth";
        darwin = true;
        # HT: @mhanberg
        # REF: https://github.com/mhanberg/.dotfiles/blob/main/flake.nix#L99-L104
        script = ''
          git clone https://github.com/megalithic/dotfiles-nix ~/.dotfiles
          bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          nix run nix-darwin -- switch --flake ~/.dotfiles
          nix run home-manager/master -- switch --flake ~/.dotfiles
        '';
      };
    };
}
