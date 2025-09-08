# REFS:
# huge amount of info on agenix, darwin, docker, devops nix things: https://github.com/carjorvaz/nixos/blob/master/hosts/mac.nix
# useful hm and darwin config with nvim/mise use/xdgConfig/home.file/more: https://github.com/yoshi12u/dotfile
# mise, hm, darwin, jujutsu, and more: https://github.com/schemar/dotfiles
# again, darwin, hm, mise/mise hooks/moretools, neat packages setup per host: https://github.com/matchai/dotfiles/blob/main/apps/packages.nix
# neat python packages setup: https://github.com/f4z3r/nix/blob/master/home/home.nix#L189
# devshells and flake-utils: https://github.com/PorcoRosso85/dev/blob/main/flake.nix
# setup agenix for secrets: https://github.com/ryantm/agenix?tab=readme-ov-file#using-agenix-with-home-manager
# use of home.file examples: https://github.com/neuralgremlin/dotfiles/blob/main/nix/home.nix#L28-L37
# nvim and dotfiles for codespaces, zsh and more: https://github.com/SushyDev/dotfiles
# also, from same author as above (sushydev - nix-plist-manager author): https://github.com/SushyDev/nixdarwin/tree/main
# showing how to use nvim in nix with package setup local to nvim.nix and xdgConfig: https://github.com/noghartt/nixcfg/blob/main/nix/home/nvim.nix
# ai ethanholz dudes nix setup:  https://tangled.sh/@ethanholz.com/nix-config/blob/main/lib/shared/lsp.nix

# -------------------------------------------------------------------------------------------------

{ pkgs
, lib
, inputs
, system
, currentSystemVersion
, ...
}:

{
  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];

  imports = [
    ./packages.nix
    ./homebrew.nix
    #   ./git.nix
    #   ./helix.nix
    #   ./himalaya.nix
    #   ./nvim.nix
    #   ./starship.nix
    #   ./tmux.nix
  ];



  xdg.enable = true;
  # TODO: move this to ./home-manager/modules/darwin or something
  xdg.configFile."hammerspoon" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config/hammerspoon;
  };
  xdg.configFile."kanata" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config/kanata;
  };
  xdg.configFile."nvim".source = config/nvim;
  xdg.configFile."tmux".source = config/tmux;
  xdg.configFile."ghostty".source = config/ghostty;

  xdg.configFile."opencode/opencode.json".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
        "ollama": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Ollama (local)",
          "options": {
            "baseURL": "http://localhost:11434/v1"
          },
          "models": {
            "gpt-oss:20b": {
              "name": "GPT OSS:20b"
            }
          }
        }
      },
      "model": "anthropic/claude-sonnet-4-20250514",
      "small_model": "anthropic/claude-3-5-haiku-20241022"
    }
  '';

  home = {
    # Necessary for home-manager to work with flakes, otherwise it will
    # look for a nixpkgs channel.
    stateVersion =
      if pkgs.stdenv.isDarwin
      then currentSystemVersion
      else system.stateVersion;

    sessionVariables = {
      ANTHROPIC_API_KEY = "op://Private/Claude/credential";
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # get nightly
    neovim.package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    # fish = {
    #   enable = true;
    #   interactiveShellInit = ''
    #     set fish_greeting # N/A
    #   '';
    #   shellAliases = {
    #     opencode = "op run --no-masking -- opencode";
    #   };
    # };


    chromium = {
      enable = true;
      package = pkgs.brave-nightly;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      ];
      commandLineArgs = [
        "--disable-features=WebRtcAllowInputVolumeAdjustment"
      ];
    };

    # alts: https://github.com/nmattia/niv?tab=readme-ov-file#getting-started
    nh = {
      enable = true;
      package = pkgs.unstable.nh;
      clean.enable = true;
      flake = ../../.;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    jujutsu = {
      enable = true;
      package = pkgs.unstable.jujutsu;
      settings = {
        user = {
          name = "Seth Messer";
          email = "seth@megalithic.io";
        };
        ui.default-command = "log";
        fix.tools.nixfmt = {
          command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" "$path" ];
          patterns = [ "glob:'**/*.nix'" ];
        };
        templates.draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };


  programs.ssh.matchBlocks."* \"test -z $SSH_TTY\"".identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      auto_install = true;
    };

    globalConfig = {
      tools = {
        elixir = "1.18.4-otp-27"; # alts: 1.18.4-otp-28
        erlang = "27.3.4.1"; # alts: 28.0.1
        python = "3.13.4";
        rust = "beta";
        node = "lts";
        pnpm = "latest";
        aws-cli = "2";
        claude = "latest";
        gemini-cli = "latest";
      };
    };
  };

  # services.ollama.enable = true;
}
