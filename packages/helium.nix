# { ... }:
# (final: prev: {
#   helium = prev.stdenv.mkDerivation (finalAttrs: {
#     pname = "helium";
#     version = "0.4.13.1";
#
#     src = prev.fetchurl {
#       url = "https://github.com/imputnet/helium-macos/releases/download/${finalAttrs.version}/helium_${finalAttrs.version}_arm64-macos.dmg";
#       hash = "sha256-3j4souWY+4EGPSQR6uURjyqu3bkB5G9xuJbvOk9cZd8=";
#     };
#
#     nativeBuildInputs = [
#       prev._7zz
#       prev.makeWrapper
#     ];
#
#     unpackPhase = ''
#       7zz x -snld $src
#     '';
#
#     dontPatchShebangs = true;
#     sourceRoot = "Helium.app";
#
#     installPhase = ''
#       mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
#       cp -R . "$out/Applications/${finalAttrs.sourceRoot}"
#       makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/${prev.lib.strings.removeSuffix ".app" finalAttrs.sourceRoot}" \
#       $out/bin/${finalAttrs.pname};
#     '';
#   });
# })
{
  lib,
  stdenv,
  fetchurl,
  finalAttrs,
  prev,
}:
stdenv.mkDerivation {
  pname = "helium";
  version = "0.4.13.1";

  src = fetchurl {
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
    makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/${lib.strings.removeSuffix ".app" finalAttrs.sourceRoot}" \
    $out/bin/${finalAttrs.pname};
  '';
}
