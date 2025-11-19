# REF:
# - https://github.com/ayla6/nixcfg/blob/main/modules/home/programs/helium/default.nix
# - https://github.com/isabelroses/dotfiles/blob/main/modules/home/programs/chromium.nix
# - https://github.com/will-lol/.dotfiles/blob/main/overlays/helium.nix
#
{lib, ...}: (final: prev: {
  helium = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "helium";
    version = "0.4.13.1";

    src = prev.fetchurl {
      url = "https://github.com/imputnet/helium-macos/releases/download/${finalAttrs.version}/helium_${finalAttrs.version}_arm64-macos.dmg";
      hash = "sha256-3j4souWY+4EGPSQR6uURjyqu3bkB5G9xuJbvOk9cZd8=";
    };

    nativeBuildInputs = [
      prev._7zz
      prev.makeWrapper
    ];

    unpackPhase = ''
      7zz x -snld $src
    '';

    dontPatchShebangs = true;
    sourceRoot = "Helium.app";

    installPhase = ''
      mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
      cp -R . "$out/Applications/${finalAttrs.sourceRoot}"
      makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/${prev.lib.strings.removeSuffix ".app" finalAttrs.sourceRoot}" \
      $out/bin/${finalAttrs.pname}
    '';

    # Comprehensive metadata (2025 standard)
    meta = with lib; {
      description = "Privacy-focused web browser based on ungoogled-chromium (generated via nix overlay)";
      longDescription = ''
        Helium is a "bs-free" web browser built on ungoogled-chromium
        that prioritizes privacy and user experience. It aims to provide an
        honest, comfortable, privacy-respecting, and non-invasive browsing experience.
      '';
      homepage = "https://github.com/imputnet/helium-chromium";
      downloadPage = "https://github.com/imputnet/helium-macos/releases";
      changelog = "https://github.com/imputnet/helium-macos/releases/tag/${version}";
      license = licenses.gpl3Only;
      platforms = platforms.darwin;
      # maintainers = with maintainers; [
      #   # Add your maintainer info here
      # ];
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      # Mark as unfree if needed
      # unfree = true;
      mainProgram = "helium";
      # Supported macOS versions
      broken = prev.stdenv.isDarwin && prev.stdenv.system == "x86_64-darwin" && lib.versionOlder prev.stdenv.hostPlatform.darwinMinVersion "10.15";
    };
  });
})
