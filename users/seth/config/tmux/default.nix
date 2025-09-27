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
    extraConfig = ''
      source -q ${config.home.homeDirectory}/code/dotfiles-nix/users/${username}/config/tmux/tmux.conf
      if-shell 'test -f "${config.home.homeDirectory}/code/dotfiles-nix/users/${username}/config/tmux/megaforest.tmux.conf"' 'source -q ${config.home.homeDirectory}/code/dotfiles-nix/users/${username}/config/tmux/megaforest.tmux.conf'

      ${lib.concatStrings (map (x: "run-shell ${x.rtp}\n") tmuxPlugins)}

      source -q ${config.home.homeDirectory}/code/dotfiles-nix/users/${username}/config/tmux/plugins.tmux.conf
    '';

    # Don't use tmux-sensible for now because it tries
    # using reattach-to-user-namespace which causes a
    # warning in every pane on Catalina
    # sensibleOnTop = false;

    # Assumes the presence of a /run directory, which we don't have on
    # macOS
    # secureSocket = false;
  };
}
