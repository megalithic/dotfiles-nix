# { pkgs, lib, ... }:
#
# {
#   # part of mksystem.nix modules
#   # system.stateVersion = 5;
#
#   # This makes it work with the Determinate Nix installer
#   ids.gids.nixbld = 30000;
#
#   # Auto upgrade nix package and the daemon service.
#   nix.enable = false;
#   nix.extraOptions = ''
#     experimental-features = nix-command flakes
#     extra-platforms = x86_64-darwin aarch64-darwin
#     keep-outputs = true
#     keep-derivations = true
#   '';
#
#   # do garbage collection bi-daily to keep disk usage low
#   nix.gc = {
#     automatic = lib.mkDefault true;
#     options = lib.mkDefault "--delete-older-than 5d";
#   };
#
#   programs.gnupg.agent.enable = true;
#
#   # zsh is the default shell on Mac and we want to make sure that we're
#   # configuring the rc correctly with nix-darwin paths.
#   programs.zsh.enable = true;
#   programs.zsh.shellInit = ''
#     # Nix
#     if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
#       . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
#     fi
#     # End Nix
#   '';
#
#   programs.fish.enable = true;
#   programs.fish.shellInit = ''
#     # Nix
#     if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
#       source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
#     end
#     # End Nix
#   '';
#
#   environment.shells = with pkgs; [ bashInteractive zsh fish ];
#   # List packages installed in system profile. To search by name, run:
#   # $ nix-env -qaP | grep wget
#   environment.systemPackages = with pkgs; [ home-manager ];
# }

{ pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.home-manager
  ];

  # Auto upgrade nix package and the daemon service.
  nix.enable = false;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true; # default shell on catalina
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;
}
