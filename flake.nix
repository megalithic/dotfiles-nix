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
    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   flake = false;
    # };
    # homebrew-bundle = {
    #   url = "github:homebrew/homebrew-bundle";
    #   flake = false;
    # };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # gift-wrap = {
    #   url = "github:tgirlcloud/gift-wrap";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     hercules-ci-effects.follows = "";
    #     flake-compat.follows = "";
    #     git-hooks.follows = "";
    #     treefmt-nix.follows = "";
    #   };
    # };

    # firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    # firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    # zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    # zen-browser.inputs.home-manager.follows = "home-manager";
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
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # emmylua-analyzer-rust = {
    #   url = "github:EmmyLuaLs/emmylua-analyzer-rust";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # mac-app-util = {
    #   url = "github:hraban/mac-app-util";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: let
    # NOTE: currently just supports one host/user
    username = "seth";
    system = "aarch64-darwin";
    arch = system;
    hostname = "megabookpro";
    version = "25.05";

    lib = nixpkgs.lib.extend (import ./lib/default.nix inputs);
    # inherit (lib) foldl recursiveUpdate mapAttrsToList;

    # forAllSystems =
    #   f:
    #   lib.genAttrs lib.systems.flakeExposed (
    #     system:
    #     f (
    #       import nixpkgs {
    #         inherit system;
    #         config.allowUnfree = true;
    #         overlays = [ neovim-nightly-overlay.overlays.default ];
    #       }
    #     )
    #   );

    # pkgs = nixpkgs.legacyPackages.${system};
    overlays = [
      inputs.jujutsu.overlays.default
      inputs.yazi.overlays.default
      inputs.nur.overlays.default

      # https://github.com/will-lol/.dotfiles/blob/main/overlays/helium.nix

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
        notmuch = prev.notmuch.override {withEmacs = false;};

        neomutt = prev.neomutt.override {
          enableLua = true;
        };

        karabiner-driverkit = prev.callPackage ./packages/karabiner-driverkit {};
        # inherit (inputs.emmylua-analyzer-rust.packages.${prev.system}) emmylua_ls emmylua_check;
      })
    ];

    mkInit = {
      system,
      script ? ''
        echo "no default app init script set."
      '',
    }: let
      pkgs = nixpkgs.legacyPackages.${system};
      # REF: https://gist.github.com/monadplus/3a4eb505633f5b03ef093514cf8356a1
      init = pkgs.writeShellApplication {
        name = "init";
        text = script;
      };
    in {
      type = "app";
      program = "${init}/bin/init";
    };
    # inherit (self) outputs;
  in {
    inherit (self) outputs;

    # apps."x86_64-linux".default = mkInit { system = "x86_64-linux"; };
    # apps."aarch64-linux".default = mkInit { system = "aarch64-linux"; };
    apps."${arch}".default = mkInit {
      system = "${arch}";
      script = builtins.readFile scripts/${arch}_bootstrap.sh;
    };

    # Build darwin flake using:
    # darwin-rebuild switch --flake ~/nix
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system lib;

      specialArgs = {inherit self inputs username system hostname version overlays;};
      modules = [
        {system.configurationRevision = self.rev or self.dirtyRev or null;}

        {nixpkgs.overlays = overlays;}
        {nixpkgs.config.allowUnfree = true;}

        ./hosts/${hostname}.nix
        ./modules/shared/darwin/system.nix
        # ./modules/shared/darwin/kanata.nix

        home-manager.darwinModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./users/${username}/home.nix;
            #   imports = [
            #     ./users/${username}/home.nix
            #     # inputs.mac-app-util.homeManagerModules.default
            #   ];
            # };
            extraSpecialArgs = {inherit inputs username system hostname version overlays;};
          };

          # homeModules.default = import ./users/${username}/home.nix;
        }

        # inputs.nix-homebrew.darwinModules.nix-homebrew
        # {
        #   nix-homebrew = {
        #     # Install Homebrew under the default prefix
        #     enable = true;
        #     # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        #     enableRosetta = true;
        #     # User owning the Homebrew prefix
        #     user = username;
        #     autoMigrate = true;
        #     # Optional: Declarative tap management
        #     taps = {
        #       "homebrew/homebrew-core" = inputs.homebrew-core;
        #       "homebrew/homebrew-cask" = inputs.homebrew-cask;
        #       "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        #     };
        #     # Optional: Enable fully-declarative tap management
        #     # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
        #     mutableTaps = false;
        #   };
        # }
      ];
    };

    # formatter = forAllSystems (pkgs: pkgs.treefmt.withConfig (import ./format.nix { inherit pkgs; }));
    #
    # devShells = forAllSystems (pkgs: {
    #   default = pkgs.mkShellNoCC {
    #     packages = [
    #       self.formatter.${pkgs.stdenv.hostPlatform.system}
    #       pkgs.selene
    #       pkgs.stylua
    #       pkgs.lua-language-server
    #       pkgs.taplo
    #       pkgs.nvfetcher
    #     ];
    #   };
    # });
    #
    # packages = forAllSystems (pkgs: {
    #   nvim = gift-wrap.legacyPackages.${pkgs.system}.wrapNeovim {
    #     pname = "mega";
    #
    #     basePackage = pkgs.neovim-unwrapped;
    #
    #     aliases = [
    #       "vi"
    #       "vim"
    #       "nv"
    #     ];
    #
    #     keepDesktopFiles = true;
    #
    #     # your user conifguration, this should be a path your nvim config in lua
    #     userConfig = ./users/${username}/config/nvim;
    #
    #     # all the plugins that should be stored in the neovim start directory
    #     # these are the plugins that are loaded when neovim starts
    #     startPlugins = with pkgs.vimPlugins; [
    #       sqlite-lua
    #       nvim-treesitter.withAllGrammars
    #       nvim-lspconfig
    #       mini-nvim
    #       nvim-colorizer-lua
    #       mini-icons
    #       todo-comments-nvim
    #       indent-blankline-nvim
    #       neo-tree-nvim
    #       mini-surround
    #       undotree
    #       direnv-vim
    #       gitsigns-nvim
    #       nui-nvim
    #       lz-n
    #       lazy.nvim
    #     ];
    #
    #     # these are plugins that are loaded on demand by your configuration
    #     optPlugins = with pkgs.vimPlugins; [
    #       blink-cmp
    #       telescope-nvim
    #       lazygit-nvim
    #     ];
    #
    #     # these are any extra packages that should be available in your neovim environment
    #     extraPackages = with pkgs; [
    #       ripgrep
    #       fd
    #       inotify-tools
    #       lazygit
    #     ];
    #   };
    # });
    # defaultPackage = forAllSystems (pkgs: self.packages.${pkgs.system}.nvim);
  };
}
