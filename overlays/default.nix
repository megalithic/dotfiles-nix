# All overlays combined
#
# Usage in flake.nix:
#   overlays = import ./overlays { inherit inputs lib; };
#
{
  inputs,
  lib,
}: [
  # External overlays
  inputs.nur.overlays.default
  inputs.fenix.overlays.default
  inputs.mcp-servers-nix.overlays.default

  # Unstable/stable package sets + input packages
  (final: prev: {
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
    mcphub = inputs.mcp-hub.packages.${prev.stdenv.hostPlatform.system}.default;
    nvim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;
    notmuch = prev.notmuch.override {withEmacs = false;};
    expert = inputs.expert.packages.${prev.stdenv.hostPlatform.system}.default;
  })

  # Custom packages (callPackage style)
  (final: prev: {
    chrome-devtools-mcp = prev.callPackage ../pkgs/chrome-devtools-mcp.nix {};
  })

  # macOS apps (mkApp style)
  (import ./apps.nix {inherit lib;})
]
