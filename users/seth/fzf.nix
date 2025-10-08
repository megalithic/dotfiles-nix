{
  config,
  pkgs,
  username,
  hostname,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true; # broken?
    defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden  --no-ignore-vcs --follow --exclude .git --exclude .jj --exclude .direnv --exclude node_modules --strip-cwd-prefix";
    defaultOptions = [
      # "--style=minimal"
      # "--style=full"
      # "--style=default"
      # "--border-label=' '"
      # "--input-label=' '"
      # "--header-label=' '"
      "--inline-info"
      "--select-1"
      "--ansi"
      "--highlight-line"
      # "--info=inline-right"
      "--no-border"
      "--border=none"
      "--reverse"
      "--extended"
      "--cycle"
      "--preview-window=right:60%"
      "--preview='preview {}'"
      "--preview-window=noborder"
      "--margin=0,0"
      "--padding=0,0"
      # ''
      #   --border --padding 1,2 \
      #   --preview='fzf-preview.sh {}' \
      #   --bind 'result:transform-list-label:
      #       if [[ -z $FZF_QUERY ]]; then
      #         echo " $FZF_MATCH_COUNT items "
      #       else
      #         echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
      #       fi
      #       ' \
      #   --bind 'focus:transform-preview-label:[[ -n {} ]] && printf " Previewing [%s] " {}' \
      #   --bind 'focus:+transform-header:file --brief {} || echo "No file selected"' \
      #   --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' \
      #   --color 'border:#aaaaaa,label:#cccccc' \
      #   --color 'preview-border:#9999cc,preview-label:#ccccff' \
      #   --color 'list-border:#669966,list-label:#99cc99' \
      #   --color 'input-border:#996666,input-label:#ffcccc' \
      #   --color 'header-border:#6699cc,header-label:#99ccff'
      # ''
      #
      "--bind=ctrl-j:ignore,ctrl-k:ignore"
      "--bind=ctrl-j:down,ctrl-k:up"
      # "--bind=ctrl-d:preview-down,ctrl-u:preview-up" # ctrl-d / ctrl-u scroll the preview pane
      "--bind=ctrl-b:preview-up,ctrl-f:preview-down"
      "--bind=ctrl-u:abort"
      "--bind=esc:abort"
      "--bind=ctrl-c:abort"
      "--bind=?:toggle-preview"
      "--bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
      # "--height=22%"
      "--prompt=' '"
      # "--pointer=' '"
      "--pointer=' '"
      "--header=' '"
      "--marker='✓ '"
      "--scrollbar='▓'"
      # "--marker='󰛄 '"
      # "--color=border:#aaaaaa,label:#cccccc"
      # "--color=preview-border:#9999cc,preview-label:#ccccff"
      # "--color=list-border:#669966,list-label:#99cc99"
      # "--color=input-border:#996666,input-label:#ffcccc"
      # "--color=header-border:#6699cc,header-label:#99ccff"
      # "--color=fg:#9DA9A0,hl:#8bd5ca,fg+:#333C43,bg+:#9DA9A0,hl+:#8bd5ca,info:#7f8c8d,prompt:#9DA9A0,spinner:-1,pointer:-1,gutter:-1,info:#939ab7,border:-1"
      "--color=bg:#2f3d44,bg+:#323d43,spinner:#8ec07c,hl:#fabd2f,gutter:#3c474d"
      "--color=fg:#d8caac,fg+:#fbf1c7,header:#83a598,info:#fabd2f,pointer:#8ec07c"
      "--color=marker:#d3869b,prompt:#fabd2f,hl+:#d65d0e"
      "--color=border:#3c474d,label:#aeaeae,query:#c0caf5"
      # "--bind 'ctrl-y:execute-silent(${pkgs.toybox}/bin/printf {} | ${pkgs.toybox}/bin/cut -f 2- | ${pkgs.wl-clipboard}/bin/wl-copy --trim-newline)'"
    ];
    fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --no-ignore-vcs --follow --strip-cwd-prefix --exclude .git --exclude .jj --exclude .direnv";
    # fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --no-ignore-vcs --follow --strip-cwd-prefix --exclude .git --exclude .jj --exclude .direnv . \\$dir";
    # fileWidgetCommand = "${pkgs.fd}/bin/fd --hidden --exclude .git --strip-cwd-prefix";
    fileWidgetOptions = [
      "--preview='preview {}'"
      # "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range :300 {}'"
      # "--header=\"find files [$(tput setaf 255)ctrl-y$(tput sgr 0): $(tput setaf 245)copy to clipboard$(tput sgr 0)]\""
      # "--preview=\"if [ -d {} ]; then ${pkgs.eza}/bin/eza --tree --color=always {} | head -200; else ${pkgs.bat}/bin/bat -n --color=always --style=numbers --line-range :500 {}; fi\""
      # "--style=minimal"
    ];
    tmux.enableShellIntegration = true;
    tmux.shellIntegrationOptions = [
      "-d 40%"
      # "--border=none"
      # "--preview-window=noborder"
      # "--padding=0,1"
    ];
  };
}
