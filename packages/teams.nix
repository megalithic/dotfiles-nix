{lib, ...}: final: prev: {
  teams = prev.stdenv.mkDerivation (finalAttrs: {
    pname = "teams";
    version = "25255.703.3981.5698";
    hash = "sha256-p9tAvOJxoIO0d8z0qdfc4sokUNfaYKq2NtBHKOWYBM4=";

    meta = with lib; {
      description = "Microsoft Teams";
      homepage = "https://teams.microsoft.com";
      downloadPage = "https://teams.microsoft.com/downloads";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      platforms = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mainProgram = "teams";
    };

    appName = "Microsoft Teams.app";

    src = prev.fetchurl {
      url = "https://statics.teams.cdn.office.net/production-osx/${finalAttrs.version}/MicrosoftTeams.pkg";
      inherit (finalAttrs) hash;
    };

    nativeBuildInputs = with prev; [
      xar
      pbzx
      cpio
    ];

    unpackPhase = ''
      xar -xf $src
    '';

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      workdir=$(pwd)
      APP_DIR=$out/Applications
      mkdir -p $APP_DIR
      cd $APP_DIR
      echo "APPDIR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!             $APP_DIR"
      pbzx -n "$workdir/MicrosoftTeams_app.pkg/Payload" | cpio -idm
      runHook postInstall
    '';
  });
}
