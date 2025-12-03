{
  inputs,
  lib,
  ...
}: [
  inputs.nur.overlays.default
  inputs.fenix.overlays.default
  # inputs.yazi.overlays.default

  (final: prev: rec {
    stable = import inputs.nixpkgs-stable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      config.allowUnfreePredicate = _: true;
    };
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      config.allowUnfreePredicate = _: true;
    };
    ai-tools = inputs.nix-ai-tools.packages.${prev.stdenv.hostPlatform.system};
    mcphub = inputs.mcp-hub.packages."${prev.stdenv.hostPlatform.system}".default;
    nvim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;
    notmuch = prev.notmuch.override {withEmacs = false;};
    expert = inputs.expert.packages.${prev.stdenv.hostPlatform.system}.default;
  })
  (import ./packages/installer.nix {inherit inputs lib;})
]
