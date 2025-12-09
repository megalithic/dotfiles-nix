{
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  home.packages = with pkgs; [
    # fonts ---------------------------------------------------------------------------------------
    atkinson-hyperlegible
    inter
    jetbrains-mono
    emacs-all-the-icons-fonts
    # joypixels
    fira-code
    fira-mono
    font-awesome
    victor-mono
    maple-mono.NF
    maple-mono.truetype
    maple-mono.variable
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.iosevka
    nerd-fonts.victor-mono
    twemoji-color-font
  ];
}
