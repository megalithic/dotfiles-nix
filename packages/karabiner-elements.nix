{lib, ...}: (final: prev: {
  karabiner-elements = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "karabiner-elements";
    version = "15.7.0";

    src = prev.fetchurl {
      url = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v${finalAttrs.version}/Karabiner-Elements-${finalAttrs.version}.dmg";
      hash = "sha256-Uy0k4xxkr33j92jxEhD/6DF0hhkdf8acU7lr3hTaFa4=";
    };

    nativeBuildInputs = [
      prev._7zz
      prev.makeWrapper
    ];

    unpackPhase = ''
      7zz x -snld $src
    '';

    dontPatchShebangs = true;
    sourceRoot = "Karabiner-Elements.app";

    installPhase = ''
      mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
      cp -R . "$out/Applications/${finalAttrs.sourceRoot}"

      # Create wrapper script for CLI access
      mkdir -p $out/bin
      makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/Karabiner-Elements" \
        $out/bin/${finalAttrs.pname}
    '';

    meta = with lib; {
      description = "Powerful keyboard customizer for macOS";
      longDescription = ''
        Karabiner-Elements is a powerful utility for keyboard customization on macOS.
        It allows you to remap keys, create complex modifications, and customize
        keyboard behavior to suit your workflow.
      '';
      homepage = "https://karabiner-elements.pqrs.org/";
      downloadPage = "https://github.com/pqrs-org/Karabiner-Elements/releases";
      changelog = "https://karabiner-elements.pqrs.org/docs/releasenotes/";
      license = licenses.publicDomain; # Unlicense
      platforms = platforms.darwin;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      mainProgram = "karabiner-elements";
    };
  });
})
