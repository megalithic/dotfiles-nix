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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "nix-darwin";
    };
    # opnix = {
    #   url = "github:brizzbuzz/opnix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    mcp-hub.url = "github:ravitemer/mcp-hub";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    nix-ai-tools.inputs.nixpkgs.follows = "nixpkgs";
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-casks = {
      url = "github:atahanyorganci/nix-casks/archive";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    expert.url = "github:elixir-lang/expert";
    # op-shell-plugins = {
    #   url = "github:1password/shell-plugins";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    # firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    # zen-browser.inputs.home-manager.follows = "home-manager";
    # yazi.url = "github:sxyazi/yazi";
    # yazi-plugins = {
    #   url = "github:yazi-rs/plugins";
    #   flake = false;
    # };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    agenix,
    # opnix,
    fenix,
    ...
  } @ inputs: let
    username = "seth";
    arch = "aarch64-darwin";
    hostname = "megabookpro";
    version = "25.11";

    lib = nixpkgs.lib.extend (import ./lib/default.nix inputs);
    overlays = import ./overlays.nix {inherit inputs nixpkgs nixpkgs-unstable lib;};

    mkInit = {
      arch,
      script ? ''
        echo "no default app init script set."
      '',
    }: let
      pkgs = nixpkgs.legacyPackages.${arch};
      # REF: https://gist.github.com/monadplus/3a4eb505633f5b03ef093514cf8356a1
      init = pkgs.writeShellApplication {
        name = "init";
        text = script;
      };
    in {
      type = "app";
      program = "${init}/bin/init";
    };
  in {
    inherit (self) outputs;

    apps."${arch}".default = mkInit {
      inherit arch;
      script = builtins.readFile scripts/${arch}_bootstrap.sh;
    };

    packages.${arch}.default = fenix.packages.${arch}.minimal.toolchain;

    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit lib;

      specialArgs = {inherit self inputs username arch hostname version overlays lib;};
      modules = [
        {system.configurationRevision = self.rev or self.dirtyRev or null;}

        {nixpkgs.overlays = overlays;}
        {nixpkgs.config.allowUnfree = true;}

        ./hosts/${hostname}.nix
        ./modules/darwin/system.nix
        ./modules/darwin/native-pkg-installer.nix

        agenix.darwinModules.default
        # opnix.darwinModules.default

        home-manager.darwinModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./users/${username}/home.nix;
            extraSpecialArgs = {inherit inputs username arch hostname version overlays lib;};
          };
        }
      ];
    };
  };
}
