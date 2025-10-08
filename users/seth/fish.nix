{
  config,
  pkgs,
  username,
  hostname,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.fish = {
    # REF: https://github.com/agdral/home-default/blob/main/shell/fish/functions/develop.nix
    enable = true;
    shellInit = ''
      export PATH="/etc/profiles/per-user/${username}/bin:$PATH"
      set -g fish_prompt_pwd_dir_length 20
    '';
    interactiveShellInit = ''
      # fish_add_path /opt/homebrew/bin
      # fish_default_key_bindings

      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore
      set fish_cursor_visual      underscore blink

      # quickly open text file
      bind -M insert ctrl-o '${pkgs.fzf}/bin/fzf | xargs -r $EDITOR'
      bind ctrl-o '${pkgs.fzf}/bin/fzf | xargs -r $EDITOR'

      bind -M insert ctrl-a beginning-of-line
      bind -M insert ctrl-e end-of-line
      bind -M insert ctrl-y accept-autosuggestion
      bind ctrl-y accept-autosuggestion

      # NOTE: using fzf for this:
      # bind -M insert ctrl-r history-pager
      # bind ctrl-r history-pager

      # edit command in $EDITOR
      bind -M insert ctrl-v edit_command_buffer
      bind ctrl-v edit_command_buffer

      # Rerun previous command
      bind -M insert ctrl-s 'commandline $history[1]' 'commandline -f execute'

      # restore old ctrl+c behavior; it should not clear the line in case I want to copy it or something
      # the new default behavior is stupid and bad, it just clears the current prompt
      # https://github.com/fish-shell/fish-shell/issues/11327
      bind -M insert -m insert ctrl-c cancel-commandline

      # I like to keep the prompt at the bottom rather than the top
      # of the terminal window so that running `clear` doesn't make
      # me move my eyes from the bottom back to the top of the screen;
      # keep the prompt consistently at the bottom
      # _prompt_move_to_bottom # call function manually to load it since event handlers don't get autoloaded

      bind -M insert \cd '${pkgs.fd}/bin/fd --type d | fzf | xargs -r'
      bind \cd '${pkgs.fd}/bin/fd --type d | fzf | xargs -r'
      #
      # # Theme inspired by Everforest with darker background
      # # Base colors
      # set -g fish_color_normal d3c6aa
      # set -g fish_color_command a7c080
      # set -g fish_color_keyword d699b6
      # set -g fish_color_quote e69875
      # set -g fish_color_redirection 7fbbb3
      # set -g fish_color_end e67e80
      # set -g fish_color_error e67e80
      # set -g fish_color_param d3c6aa
      # set -g fish_color_comment 859289
      # set -g fish_color_selection --background=3c474d
      # set -g fish_color_search_match --background=3c474d
      # set -g fish_color_operator 7fbbb3
      # set -g fish_color_escape d699b6
      # set -g fish_color_autosuggestion 6c7b77
      #
      # # Darker background settings
      # set -g fish_color_host_remote d699b6
      # set -g fish_color_host 7fbbb3
      # set -g fish_color_cancel e67e80
      # set -g fish_pager_color_prefix 7fbbb3
      # set -g fish_pager_color_completion d3c6aa
      # set -g fish_pager_color_description 6c7b77
      # set -g fish_pager_color_progress 7fbbb3
      #
      # # Set darker background for prompt
      # set -g fish_color_cwd_root e67e80
      # set -g fish_color_user 7fbbb3

      # everforest
      set -l foreground d3c6aa
      set -l selection 2d4f67
      set -l comment 859289
      set -l red e67e80
      set -l orange ff9e64
      set -l yellow dbbc7f
      set -l green a7c080
      set -l purple d699b6
      set -l cyan 7fbbb3
      set -l pink d699b6

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment
    '';
    functions = {
      fish_greeting = "";
      _prompt_move_to_bottom = {
        onEvent = "fish_postexec";
        body = "tput cup $LINES";
      };
      # nix-shell = {
      #   wraps = "nix-shell";
      #   body = ''
      #     for ARG in $argv
      #         if [ "$ARG" = --run ]
      #             command nix-shell $argv
      #             return $status
      #         end
      #     end
      #     command nix-shell $argv --run "exec fish"
      #   '';
      # };
      pr = ''
        set -l PROJECT_PATH (git config --get remote.origin.url)
        set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
        set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
        set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
        set -l GIT_BRANCH (git branch --show-current || echo "")
        set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

        if test -z "$GIT_BRANCH"
            set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
        end

        if test -z "$GIT_BRANCH"
            echo "Error: not a git repository"
            return 1
        end
        ${
          if isDarwin
          then "open"
          else "xdg-open"
        } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
      '';
      ghb = ''
        set -l PROJECT_PATH (git config --get remote.origin.url)
        set -l PROJECT_PATH (string replace "git@github.com:" "" "$PROJECT_PATH")
        set -l PROJECT_PATH (string replace "https://github.com/" "" "$PROJECT_PATH")
        set -l PROJECT_PATH (string replace ".git" "" "$PROJECT_PATH")
        set -l GIT_BRANCH (git branch --show-current || echo "")
        set -l MASTER_BRANCH (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

        if test -z "$GIT_BRANCH"
            set GIT_BRANCH (jj log -r @- --no-graph --no-pager -T 'self.bookmarks()')
        end

        if test -z "$GIT_BRANCH"
            echo "Error: not a git repository"
            return 1
        end
        ${
          if isDarwin
          then "open"
          else "xdg-open"
        } "https://github.com/$PROJECT_PATH/compare/$MASTER_BRANCH...$GIT_BRANCH"
      '';
    };

    # direnv hook fish | source
    # tv init fish | source
    # ${pkgs.trashy}/bin/trashy completions fish | source
    # ${pkgs.rqbit}/bin/rqbit -v error completions fish | source
    # ${inputs.rimi.packages.${system}.rimi}/bin/rimi completions fish | source

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --all --group-directories-first --color=always --hyperlink";
      l = "${pkgs.eza}/bin/eza --all --long --color=always --color-scale=all --group-directories-first --sort=type --hyperlink --icons=auto --octal-permissions";
      # l = "${pkgs.eza}/bin/eza -lhF --group-directories-first --color=always --icons=always --hyperlink";
      ll = "${pkgs.eza}/bin/eza -lahF --group-directories-first --color=always --icons=always --hyperlink";
      la = "${pkgs.eza}/bin/eza -lahF --group-directories-first --color=always --icons=always --hyperlink";
      tree = "${pkgs.eza}/bin/eza --tree --color=always";
      opencode = "op run --no-masking -- opencode";
      rm = "${pkgs.darwin.trash}/bin/trash -v";
      q = "exit";
      ",q" = "exit";
      mega = "ftm mega";
      copy =
        if isDarwin
        then "pbcopy"
        else "xclip -selection clipboard";
      paste =
        if isDarwin
        then "pbpaste"
        else "xlip -o -selection clipboard";
      cat = "bat";
      "!!" = "eval \\$history[1]";
      clear = "clear && _prompt_move_to_bottom";
      # inspect $PATH
      pinspect = ''echo "$PATH" | tr ":" "\n"'';
      # brew = "op plugin run -- brew";
      # cachix = "op plugin run -- cachix";
      # doctl = "op plugin run -- doctl";
      # gh = "op plugin run -- gh";
      # git = "op plugin run -- git";
      # tmux = "op plugin run -- tmux";
      # pulumi = "op plugin run -- pulumi";
    };

    shellAbbrs = {
      nvim = "nvim -O";
      vim = "nvim -O";
      j = "just";
    };

    plugins = [
      {
        name = "autopair";
        inherit (pkgs.fishPlugins.autopair) src;
      }
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk";
        };
      }
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "d6abb267bb3fb7e987a9352bc43dcdb67bac9f06";
          sha256 = "6oeyN9ngXWvps1c5QAUjlyPDQwRWAoxBiVTNmZ4sG8E=";
        };
      }
    ];
  };
}
