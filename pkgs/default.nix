# Custom packages
#
# Usage in overlays:
#   (import ./pkgs { inherit pkgs lib; })
#
# Or via callPackage:
#   pkgs.callPackage ./pkgs/chrome-devtools-mcp.nix {}
#
{
  pkgs,
  lib ? pkgs.lib,
}: {
  chrome-devtools-mcp = pkgs.callPackage ./chrome-devtools-mcp.nix {};
  karabiner-elements = import ./karabiner-elements.nix {inherit pkgs lib;};
}
