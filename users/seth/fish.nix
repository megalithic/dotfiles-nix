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
      # bind -M insert ctrl-o '${pkgs.fzf}/bin/fzf | xargs -r $EDITOR'
      # bind ctrl-o '${pkgs.fzf}/bin/fzf | xargs -r $EDITOR'

      bind -M insert ctrl-a beginning-of-line
      bind -M normal ctrl-a beginning-of-line
      bind -M default ctrl-a beginning-of-line

      bind -M insert ctrl-e end-of-line
      bind -M normal ctrl-e end-of-line
      bind -M default ctrl-e end-of-line

      bind -M insert ctrl-y accept-autosuggestion
      bind -M normal ctrl-y accept-autosuggestion
      bind -M default ctrl-y accept-autosuggestion

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

      bind -M insert ctrl-d fzf-dir-widget
      bind -M normal ctrl-d fzf-dir-widget
      bind -M default ctrl-d fzf-dir-widget

      bind -M insert ctrl-b fzf-jj-bookmarks
      bind -M normal ctrl-b fzf-jj-bookmarks
      bind -M default ctrl-b fzf-jj-bookmarks

      bind -M insert ctrl-o fzf-vim-widget
      bind -M normal ctrl-o fzf-vim-widget
      bind -M default ctrl-o fzf-vim-widget

      # everforest theme
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

      # Darker background settings
      set -g fish_color_host_remote d699b6
      set -g fish_color_host 7fbbb3
      set -g fish_color_cancel e67e80
      set -g fish_pager_color_prefix 7fbbb3
      set -g fish_pager_color_completion d3c6aa
      set -g fish_pager_color_description 6c7b77
      set -g fish_pager_color_progress 7fbbb3

      # Set darker background for prompt
      set -g fish_color_cwd_root e67e80
      set -g fish_color_user 7fbbb3
    '';
    functions = {
      fish_greeting = "";
      _prompt_move_to_bottom = {
        onEvent = "fish_postexec";
        body = "tput cup $LINES";
      };
      nix-shell = {
        wraps = "nix-shell";
        body = ''
          for ARG in $argv
              if [ "$ARG" = --run ]
                  command nix-shell $argv
                  return $status
              end
          end
          command nix-shell $argv --run "exec fish"
        '';
      };
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
      chk = ''
        # Directly use ps command because it is often aliased to a different command entirely
        # or with options that dirty the search results and preview output
        set -f ps_cmd (command -v ps || echo "ps")
        # use all caps to be consistent with ps default format
        # snake_case because ps doesn't seem to allow spaces in the field names
        set -f ps_preview_fmt (string join ',' 'pid' 'ppid=PARENT' 'user' '%cpu' 'rss=RSS_IN_KB' 'start=START_TIME' 'command')
        set -f processes_selected (
            $ps_cmd -A -opid,command | \
            ${pkgs.fzf}/bin/fzf --multi \
                        --prompt="search processes » " \
                        --query (commandline --current-token) \
                        --ansi \
                        --header=" $(tput sitm)$(tput setaf 5)processes: $(tput sgr 0)[ $(tput setaf 255)ctrl-x$(tput sgr 0): $(tput setaf 245)kill single process $(tput sgr 0)]" \
                        # first line outputted by ps is a header, so we need to mark it as so
                        --header-lines=1 \
                        # ps uses exit code 1 if the process was not found, in which case show an message explaining so
                        --preview="$ps_cmd -o '$ps_preview_fmt' -p {1} || echo 'Cannot preview {1} because it exited.'" \
                        --preview-window="right:60%:wrap" \
                        # --preview-window="top:4:wrap" \
                        --bind="ctrl-x:execute(kill {1})+change-prompt(⚡ )+reload($ps_cmd -A -opid,command)" \
                        --bind="ctrl-x:execute-silent(
                          for line in {+}; do
                            pid=\$(echo \"\$line\" | awk '{print \$2}')
                            cmd=\$(echo \"\$line\" | awk '{for(i=11;i<=NF;i++) printf \$i\" \"}' | cut -c1-60)
                            kill $pid
                            if kill \$pid 2>/dev/null; then
                              echo \"\$pid|\$cmd\" >> $killed_pids_file
                            else
                              osascript -e \"display notification 'Failed to kill PID: '\$pid' ('\$cmd')' with title 'Kill Failed' sound name 'Basso'\"
                            fi
                          done
                        )+reload(ps aux | grep -vE \"(ps aux|fzf)\")"
        )

        if test $status -eq 0
            for process in $processes_selected
                set -f --append pids_selected (string split --no-empty --field=1 -- " " $process)
            end

            # string join to replace the newlines outputted by string split with spaces
            commandline --current-token --replace -- (string join '; ' $pids_selected)
        end

        commandline --function repaint
      '';

      fzf-jj-bookmarks = ''
        set -l selected_bookmark (jj bookmark list | fzf --height 40%)
        if test -n "$selected_bookmark"
            # parse the bookmark name out of the full bookmark info line
            set -l bookmark_name (string split ":" "$selected_bookmark" | head -n 1 | string trim)
            commandline -i " $bookmark_name "
        end
        commandline -f repaint
      '';

      _fzf_preview_file = ''
        # because there's no way to guarantee that _fzf_search_directory passes the path to _fzf_preview_file
        # as one argument, we collect all the arguments into one single variable and treat that as the path
        set -f file_path $argv

        if test -L "$file_path" # symlink
            # notify user and recurse on the target of the symlink, which can be any of these file types
            set -l target_path (realpath "$file_path")

            set_color yellow
            echo "'$file_path' is a symlink to '$target_path'."
            set_color normal

            _fzf_preview_file "$target_path"
        else if test -f "$file_path" # regular file
            if set --query fzf_preview_file_cmd
                # need to escape quotes to make sure eval receives file_path as a single arg
                eval "$fzf_preview_file_cmd '$file_path'"
            else
                bat --style=numbers --color=always "$file_path"
            end
        else if test -d "$file_path" # directory
            if set --query fzf_preview_dir_cmd
                # see above
                eval "$fzf_preview_dir_cmd '$file_path'"
            else
                # -A list hidden files as well, except for . and ..
                # -F helps classify files by appending symbols after the file name
                # command ls -A -F "$file_path"
                command eza -ahFT -L=1 --color=always --icons=always --sort=size --group-directories-first "$file_path"
            end
        else if test -c "$file_path"
            _fzf_report_file_type "$file_path" "character device file"
        else if test -b "$file_path"
            _fzf_report_file_type "$file_path" "block device file"
        else if test -S "$file_path"
            _fzf_report_file_type "$file_path" socket
        else if test -p "$file_path"
            _fzf_report_file_type "$file_path" "named pipe"
        else
            command preview "$file_path"
            # echo "$file_path doesn't exist." >&2
        end
      '';

      fzf-dir-widget = ''
        # Directly use fd binary to avoid output buffering delay caused by a fd alias, if any.
        # Debian-based distros install fd as fdfind and the fd package is something else, so
        # check for fdfind first. Fall back to "fd" for a clear error message.
        set -f fd_cmd (command -v fdfind || command -v fd  || echo "fd")
        set -f --append fd_cmd --color=always $fzf_fd_opts --type d

        set -f fzf_arguments --multi --ansi $fzf_directory_opts
        set -f token (commandline --current-token)
        # expand any variables or leading tilde (~) in the token
        set -f expanded_token (eval echo -- $token)
        # unescape token because it's already quoted so backslashes will mess up the path
        set -f unescaped_exp_token (string unescape -- $expanded_token)

        # If the current token is a directory and has a trailing slash,
        # then use it as fd's base directory.
        if string match --quiet -- "*/" $unescaped_exp_token && test -d "$unescaped_exp_token"
            set --append fd_cmd --base-directory=$unescaped_exp_token
            # use the directory name as fzf's prompt to indicate the search is limited to that directory
            set --prepend fzf_arguments --prompt="Directory $unescaped_exp_token> " --preview="_fzf_preview_file $expanded_token{}"
            set -f file_paths_selected $unescaped_exp_token($fd_cmd 2>/dev/null | command fzf $fzf_arguments)
        else
            set --prepend fzf_arguments --prompt="Directory> " --query="$unescaped_exp_token" --preview='_fzf_preview_file {}'
            set -f file_paths_selected ($fd_cmd 2>/dev/null | command fzf $fzf_arguments)
        end


        if test $status -eq 0
            commandline --current-token --replace -- (string escape -- $file_paths_selected | string join ' ')
        end

        commandline --function repaint
      '';
      fzf-vim-widget = ''
        # modified from fzf-file-widget
        set -l commandline $(__fzf_parse_commandline)
        set -l dir $commandline[1]
        set -l fzf_query $commandline[2]
        set -l prefix $commandline[3]

        # "-path \$dir'*/\\.*'" matches hidden files/folders inside $dir but not
        # $dir itself, even if hidden.
        test -n "$FZF_CTRL_T_COMMAND"; or set -l FZF_CTRL_T_COMMAND "
        command find -L \$dir -mindepth 1 \\( -path \$dir'*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' \\) -prune \
        -o -type f -print \
        -o -type d -print \
        -o -type l -print 2> /dev/null | sed 's@^\./@@'"

        test -n "$FZF_TMUX_HEIGHT"; or set FZF_TMUX_HEIGHT 40%
        begin
            set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse --bind=ctrl-z:ignore $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS"
            eval "$FZF_CTRL_T_COMMAND | "(__fzfcmd)' -m --query "'$fzf_query'"' | while read -l r
                set result $result $r
            end
        end
        if [ -z "$result" ]
            # _prompt_move_to_bottom
            commandline -f repaint
            return
        end
        set -l filepath_result
        for i in $result
            set filepath_result "$filepath_result$prefix"
            set filepath_result "$filepath_result$(string escape $i)"
            set filepath_result "$filepath_result "
        end
        # _prompt_move_to_bottom
        commandline -f repaint
        $EDITOR $result
      '';
    };

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza --all --group-directories-first --color=always --hyperlink";
      l = "${pkgs.eza}/bin/eza --all --long --color=always --color-scale=all --group-directories-first --sort=type --hyperlink --icons=always --octal-permissions";
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
      pathi = ''echo "$PATH" | tr ":" "\n"'';
      # brew = "op plugin run -- brew";
    };

    shellAbbrs = {
      nvim = "nvim -O";
      vim = "nvim -O";
      j = "just";
      ju = "just";
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
