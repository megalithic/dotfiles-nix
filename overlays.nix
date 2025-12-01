# Overlay definitions for the flake
#
# Usage in flake.nix:
#   overlays = import ./overlays.nix { inherit inputs nixpkgs nixpkgs-unstable lib; };
{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  lib,
}: [
  # inputs.yazi.overlays.default
  inputs.nur.overlays.default
  inputs.fenix.overlays.default

  # This overlay makes unstable packages available through pkgs.unstable
  (final: prev: rec {
    unstable = import nixpkgs-unstable {
      inherit (prev) system;
      config.allowUnfree = true;
      config.allowUnfreePredicate = _: true;
    };
    stable = import nixpkgs {
      inherit (prev) system;
    };
    ai-tools = inputs.nix-ai-tools.packages.${prev.system};
    mcphub = inputs.mcp-hub.packages."${prev.system}".default;
    # NOTE: here's how to do a custom neovim-nightly overlay:
    # REF: https://github.com/fredrikaverpil/dotfiles/blob/main/nix/shared/overlays/neovim.nix
    nvim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
    notmuch = prev.notmuch.override {withEmacs = false;};
    expert = inputs.expert.packages.${prev.system}.default;
    neomutt = prev.neomutt.override {
      enableLua = true;
    };
  })

  (import ./packages/helium.nix {inherit lib;})
]
