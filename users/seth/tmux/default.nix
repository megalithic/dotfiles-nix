# vim: set sts=2 ts=2 sw=2 expandtab :

{ config
, pkgs
, lib
, inputs
, username
, system
, hostname
, version
, overlays
, ...
}:

let
  tmuxPlugins = with pkgs.tmuxPlugins; [
    pain-control
    sessionist
    yank
    battery
    cpu
    copycat
    open
    better-mouse-mode
    # pop
    fuzzback
    jump
    tmux-thumbs
    mode-indicator
    # cowboy
    # suspend
  ];
in
{
  programs.tmux = {
    enable = true;
    # escapeTime = 10;
    # prefix = "C-space";
    # sensibleOnTop = false;
    # shell = "${pkgs.fish}/bin/fish";
    # terminal = "xterm-ghostty";
    # plugins = tmuxPlugins;
    # # REF: http://github.com/azzen/home-manager/blob/master/tmux/plugins.nix#L18-L32
    # extraConfig = ''
    #   source-file "${config.home.homeDirectory}/.dotfiles-nix/users/${username}/tmux/tmux.conf"
    #   # source-file "${config.home.homeDirectory}/.dotfiles-nix/users/${username}/tmux/megaforest.tmux.conf"
    #
    #   ${lib.concatStrings (map (x: "run-shell ${x.rtp}\n") tmuxPlugins)}
    #
    #   # source-file "${config.home.homeDirectory}/.dotfiles-nix/users/${username}/tmux/plugins.tmux.conf"
    # '';
  };
}
