{
  pkgs,
  lib ? pkgs.lib,
  stdenvNoCC ? pkgs.stdenvNoCC,
  ...
}: {
  pname,
  version,
  url,
  sha256,
  appName ? "${pname}.app", # The .app bundle name (e.g., "MailMate.app")
  desc ? null,
  homepage ? null,
  artifactType ? "app", # "app", "pkg", or "binary"
  binaries ? [], # List of binary names for "binary" type
}: let
  # Detect artifact type based on URL if not specified
  detectedType =
    if lib.strings.hasSuffix ".pkg" url
    then "pkg"
    else artifactType;

  isPkg = detectedType == "pkg";
  isApp = detectedType == "app";
  isBinary = detectedType == "binary";
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    inherit pname version;

    src = pkgs.fetchurl {
      inherit url sha256;
    };

    nativeBuildInputs = with pkgs;
      [
        undmg
        unzip
        gzip
        bzip2
        _7zz
        file # for mime type detection
        makeWrapper
        fd # modern find alternative
        ripgrep # modern grep alternative
      ]
      ++ lib.lists.optional isPkg (
        with pkgs; [
          xar
          cpio
          gnused
          pbzx # for pbzx-compressed PKG payloads
        ]
      );

    # Unpack phase: handle different archive/package types
    unpackPhase =
      if isPkg
      then ''
        echo "Extracting PKG installer..."
        xar -xf $src

        # Helper function to extract payload (handles pbzx and gzip formats)
        extract_payload() {
          local payload="$1"
          # Check magic bytes to determine compression format
          if head -c 4 "$payload" | grep -q "pbzx"; then
            echo "  (using pbzx decompression)"
            pbzx - < "$payload" | cpio -i 2>/dev/null || true
          else
            echo "  (using gzip decompression)"
            zcat "$payload" | cpio -i 2>/dev/null || true
          fi
        }

        # Extract all package payloads
        # Use rg (ripgrep) for pattern matching
        for pkg in $(cat Distribution 2>/dev/null | rg -o "#.+\.pkg" 2>/dev/null | sed -e "s/^#//" -e "s/$/\/Payload/" || echo "*.pkg/Payload"); do
          if [ -f "$pkg" ]; then
            echo "Extracting payload: $pkg"
            extract_payload "$pkg"
          fi
        done

        # Fallback: try to extract any .pkg/Payload files directly
        for pkgfile in *.pkg; do
          if [ -d "$pkgfile" ] && [ -f "$pkgfile/Payload" ]; then
            echo "Extracting payload from $pkgfile"
            extract_payload "$pkgfile/Payload"
          fi
        done
      ''
      else if isApp
      then ''
        echo "Extracting application archive..."
        # Try different extraction methods in order based on file type
        case "$src" in
          *.dmg)
            echo "Extracting DMG..."
            undmg $src
            ;;
          *.zip)
            echo "Extracting ZIP..."
            unzip -q $src
            ;;
          *.tbz|*.tar.bz2)
            echo "Extracting tar.bz2..."
            tar -xjf $src
            ;;
          *.tgz|*.tar.gz)
            echo "Extracting tar.gz..."
            tar -xzf $src
            ;;
          *.7z)
            echo "Extracting 7zip..."
            7zz x -snld $src
            ;;
          *)
            # Fallback: try each method
            if undmg $src 2>/dev/null; then
              echo "Extracted DMG successfully"
            elif unzip -q $src 2>/dev/null; then
              echo "Extracted ZIP successfully"
            elif tar -xjf $src 2>/dev/null; then
              echo "Extracted tar.bz2 successfully"
            elif tar -xzf $src 2>/dev/null; then
              echo "Extracted tar.gz successfully"
            elif 7zz x -snld $src >/dev/null 2>&1; then
              echo "Extracted with 7zip successfully"
            else
              echo "Warning: Failed to extract archive, trying to continue..."
            fi
            ;;
        esac
      ''
      else if isBinary
      then ''
        echo "Processing binary artifact..."
        if [ "$(file --mime-type -b "$src")" == "application/gzip" ]; then
          echo "Decompressing gzipped binary..."
          gunzip $src -c > ${lib.lists.elemAt binaries 0}
        elif [ "$(file --mime-type -b "$src")" == "application/x-mach-binary" ]; then
          echo "Copying Mach-O binary..."
          cp $src ${lib.lists.elemAt binaries 0}
        else
          echo "Copying binary as-is..."
          cp $src ${lib.lists.elemAt binaries 0}
        fi
      ''
      else "";

    # Set source root for app installations
    sourceRoot = lib.strings.optionalString isApp appName;

    # Don't patch shebangs - it invalidates macOS code signatures
    dontPatchShebangs = true;
    dontFixup = true; # Preserve app bundle structure

    # Install phase: place files in appropriate locations
    installPhase =
      if isPkg
      then ''
        echo "Installing PKG contents..."

        # Install Applications
        if [ -d "Applications" ]; then
          echo "Installing to Applications..."
          mkdir -p $out/Applications
          cp -R Applications/* $out/Applications/
        fi

        # Find and install any .app bundles in root
        # Use fd (fallback to find if fd not available)
        if [ -n "$(fd -d 1 -t d '\.app$' . 2>/dev/null || true)" ]; then
          echo "Installing app bundles..."
          mkdir -p $out/Applications
          cp -R *.app $out/Applications/ 2>/dev/null || true
        fi

        # Install Resources
        if [ -d "Resources" ]; then
          echo "Installing Resources..."
          mkdir -p $out/Resources
          cp -R Resources/* $out/Resources/
        fi

        # Install Library items
        if [ -d "Library" ]; then
          echo "Installing Library items..."
          mkdir -p $out/Library
          cp -R Library/* $out/Library/
        fi
      ''
      else if isApp
      then ''
        echo "Installing application bundle..."
        mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
        cp -R . "$out/Applications/${finalAttrs.sourceRoot}"

        # Create wrapper script for CLI access
        mkdir -p $out/bin

        # Try to find the main executable
        appBaseName="${lib.strings.removeSuffix ".app" appName}"
        if [[ -e "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/$appBaseName" ]]; then
          echo "Creating wrapper for $appBaseName..."
          makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/$appBaseName" $out/bin/${pname}
        elif [[ -e "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/${pname}" ]]; then
          echo "Creating wrapper for ${pname}..."
          makeWrapper "$out/Applications/${finalAttrs.sourceRoot}/Contents/MacOS/${pname}" $out/bin/${pname}
        else
          echo "Note: Could not find main executable for wrapper"
        fi
      ''
      else if (isBinary && !isApp)
      then ''
        echo "Installing binary..."
        mkdir -p $out/bin
        install -Dm755 ./* $out/bin/
      ''
      else "";

    # Remove quarantine attributes to prevent Gatekeeper warnings
    postInstall = lib.optionalString (isApp || isPkg) ''
      echo "Removing quarantine attributes..."

      if [ -d "$out/Applications" ]; then
        # Use fd to find .app bundles and remove com.apple.quarantine
        # The -t d flag finds directories, -e app finds .app extensions
        for app in $(fd -t d -e app . "$out/Applications" 2>/dev/null || true); do
          xattr -dr com.apple.quarantine "$app" 2>/dev/null || true
        done
      fi

      # Also clear from any standalone .pkg installations
      if [ -d "$out/Library" ]; then
        xattr -dr com.apple.quarantine "$out/Library" 2>/dev/null || true
      fi
    '';

    meta = {
      description = if desc != null then desc else "macOS application";
      homepage = if homepage != null then homepage else "";
      platforms = lib.platforms.darwin;
      mainProgram =
        if (isBinary && !isApp)
        then (lib.lists.elemAt binaries 0)
        else pname;
    };
  })
