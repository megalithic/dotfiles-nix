{hs_extra_config}: {config, ...}: {
  # home.packages = with pkgs; [jq];

  # home.sessionPath = ["${nixConfigPath}/dotfiles/script-kitty"];

  home.file = {
    ".config/hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/config/hammerspoon";
    ".config/hammerspoon/nix_path.lua".text = ''
      NIX_PATH = "${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
    '';
    ".config/hammerspoon/extra_config.lua".text = hs_extra_config;
  };

  # xdg.configFile = {
  #   "hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/hammerspoon";
  #   "hammerspoon/nix_path.lua".text = ''
  #     NIX_PATH = "${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
  #   '';
  #   "hammerspoon/extra_config.lua".text = hs_extra_config;
  # };
}
