{ pkgs, ... }: {

  fonts.packages = with pkgs; [
    atkinson-hyperlegible
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    maple-mono.NF
  ];
}
