{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homeModules.kanata;
in {
  options.homeModules.kanata = {
    enable =
      mkEnableOption "kanata configuration"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.kanata];

    xdg.configFile = {
      "kanata/leeloo.kbd".source = ./leeloo.kbd;
      "kanata/macbookpro.kbd".source = ./macbookpro.kbd;
    };
  };
}
