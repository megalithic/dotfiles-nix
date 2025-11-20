{
  config,
  pkgs,
  lib,
  ...
}: let
  # Helper to create extension with local CRX file
  mkExtension = {
    id,
    version,
    sha256,
  }: {
    inherit id version;
    crxPath = pkgs.fetchurl {
      url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx3&prodversion=120.0.0.0&x=id%3D${id}%26installsource%3Dondemand%26uc";
      inherit sha256;
      name = "${id}-${version}.crx";
    };
  };

  # Extension list - update with: bin/chrome-ext-info <id> --name <name> --hash
  extensions = [
    (mkExtension {
      id = "egnjhciaieeiiohknchakcodbpgjnchh"; # tab wrangler
      version = "7.9.0";
      sha256 = "sha256-vUKTo1UFRoTKv0KeAvGx4kmVi5CEqxtIPMP1H/owI3Q=";
    })
    (mkExtension {
      id = "gfbliohnnapiefjpjlpjnehglfpaknnc"; # surfingkeys
      version = "1.17.11";
      sha256 = "sha256-JO4w4a7ASorWMwITy7YtJgI3if3NcrWBijpABnQAi0c=";
    })
    (mkExtension {
      id = "egpjdkipkomnmjhjmdamaniclmdlobbo"; # firenvim
      version = "0.2.16";
      sha256 = "sha256-QFQjBG7fOyj7rRNSby7enwCIhjXqyRPpm+AwqBM9sv4=";
    })
    (mkExtension {
      id = "cdglnehniifkbagbbombnjghhcihifij"; # kagi
      version = "1.2.2.5";
      sha256 = "sha256-weiUUUiZeeIlz/k/d9VDSKNwcQtmAahwSIHt7Frwh7E=";
    })
    (mkExtension {
      id = "dpaefegpjhgeplnkomgbcmmlffkijbgp"; # kagi-summariser
      version = "1.0.1";
      sha256 = "sha256-BnnCPisSxlhTSoQQeZg06Re8MhgwztRKmET9D93ghiw=";
    })
    # NOTE: 1Password (aeblfdkhhhdcdjpifhhbdiojplfjncoa) not available via Chrome Web Store API
    # Install manually through Helium UI or use the native app
  ];
in {
  # REF:
  # - https://github.com/will-lol/.dotfiles/blob/main/home/extensions/chromium.nix
  # - https://github.com/isabelroses/dotfiles/blob/main/modules/home/programs/chromium.nix

  programs.helium = {
    enable = true;
    bundleId = "net.imput.helium"; # macOS bundle identifier for Application Support path
    dictionaries = [pkgs.hunspellDictsChromium.en_US];
    inherit extensions;

    # Command-line arguments for Helium
    # See: https://peter.sh/experiments/chromium-command-line-switches/
    # ungoogled-chromium flags: https://github.com/ungoogled-software/ungoogled-chromium/blob/master/docs/flags.md
    commandLineArgs = [
      # Performance
      "--ignore-gpu-blocklist"
      "--disk-cache=${config.home.homeDirectory}/Library/Caches/helium"

      # Startup behavior
      "--no-first-run"
      "--no-default-browser-check"
      "--hide-crashed-bubble"

      # Privacy enhancements
      "--disable-breakpad" # Disable crash reporter
      "--disable-wake-on-wifi"
      "--no-pings" # Disable hyperlink auditing pings
      "--disable-search-engine-collection" # Prevent automatic search engine scraping

      # Helium-specific
      "--energy-saver-fps-limit=30" # Limit FPS when on battery to improve battery life

      # Feature flags (comma-separated)
      "--enable-features=TouchpadOverscrollHistoryNavigation,NoReferrers"
    ];
  };

  imports = [./extension.nix];

  # Extension files are managed by extension.nix module
  # which correctly handles the Helium directory path:
  # Library/Application Support/net.imput.helium/External Extensions/

  # ==============================================================================
  # Developer Mode & User Scripts Configuration
  # ==============================================================================
  # Enable developer mode to allow user scripts (required for SurfingKeys Advanced Mode)
  # This ensures extensions.ui.developer_mode is set in Helium's Secure Preferences
  home.activation.enableHeliumDeveloperMode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    HELIUM_PREFS="${config.home.homeDirectory}/Library/Application Support/net.imput.helium/Default/Secure Preferences"

    # Only modify if Helium profile exists
    if [ -f "$HELIUM_PREFS" ]; then
      # Check if developer_mode is already enabled
      CURRENT_VALUE=$(${pkgs.jq}/bin/jq -r '.extensions.ui.developer_mode // false' "$HELIUM_PREFS")

      if [ "$CURRENT_VALUE" != "true" ]; then
        $DRY_RUN_CMD echo "Enabling developer mode for Helium extensions..."
        if [ -z "''${DRY_RUN:-}" ]; then
          # Create backup
          cp "$HELIUM_PREFS" "$HELIUM_PREFS.backup"

          # Enable developer mode
          ${pkgs.jq}/bin/jq '.extensions.ui.developer_mode = true' "$HELIUM_PREFS" > "$HELIUM_PREFS.tmp"
          mv "$HELIUM_PREFS.tmp" "$HELIUM_PREFS"

          $DRY_RUN_CMD echo "✓ Developer mode enabled for Helium"
        fi
      else
        $DRY_RUN_CMD echo "✓ Developer mode already enabled for Helium"
      fi
    else
      $DRY_RUN_CMD echo "Helium profile not found - developer mode will be set on first run"
    fi
  '';

  # ==============================================================================
  # Widevine DRM Installation (Netflix, Amazon Prime, etc.)
  # ==============================================================================
  # Automatically installs Widevine from Brave Browser Nightly or Google Chrome
  home.activation.installWidevine = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Find Helium in nix store
    HELIUM_NIX_APP=$(ls -d /nix/store/*-helium-0.*/Applications/Helium.app 2>/dev/null | grep -v "wrapped" | sort -V | tail -1)

    if [ -z "$HELIUM_NIX_APP" ] || [ ! -d "$HELIUM_NIX_APP" ]; then
      $DRY_RUN_CMD echo "Helium package not found in nix store, skipping Widevine installation"
    else
      # Create /Applications/Helium.app as a writable copy if it doesn't exist
      HELIUM_APP="/Applications/Helium.app"

      if [ ! -d "$HELIUM_APP" ]; then
        $DRY_RUN_CMD echo "Creating writable Helium.app in /Applications..."
        $DRY_RUN_CMD echo "Note: You may be prompted for your password to copy Helium to /Applications"
        if [ -z "''${DRY_RUN:-}" ]; then
          if /usr/bin/sudo cp -R "$HELIUM_NIX_APP" /Applications/ 2>/dev/null; then
            /usr/bin/sudo chown -R $(whoami):staff "$HELIUM_APP" 2>/dev/null || true
          else
            echo "Failed to copy Helium.app. Skipping Widevine installation."
            HELIUM_APP=""  # Mark as failed to skip rest of script
          fi
        fi
      fi

      if [ -n "$HELIUM_APP" ] && [ -d "$HELIUM_APP" ]; then
        HELIUM_WIDEVINE="$HELIUM_APP/Contents/Frameworks/Helium Framework.framework/Libraries/WidevineCdm"

        # Check if Widevine is already installed
        if [ -d "$HELIUM_WIDEVINE" ] && [ -f "$HELIUM_WIDEVINE/_platform_specific/mac_arm64/libwidevinecdm.dylib" ]; then
          $DRY_RUN_CMD echo "✓ Widevine already installed in Helium"
        else
          # Try to extract from Brave Browser Nightly first
          BRAVE_NIGHTLY="/Applications/Brave Browser Nightly.app"
          BRAVE_WIDEVINE_DIR="${config.home.homeDirectory}/Library/Application Support/BraveSoftware/Brave-Browser-Nightly/WidevineCdm"
          WIDEVINE_INSTALLED=false

          if [ -d "$BRAVE_NIGHTLY" ] && [ -d "$BRAVE_WIDEVINE_DIR" ]; then
            # Find the latest Widevine version directory
            LATEST_WIDEVINE=$(find "$BRAVE_WIDEVINE_DIR" -maxdepth 1 -type d -name "[0-9]*" | sort -V | tail -1)

            if [ -n "$LATEST_WIDEVINE" ] && [ -f "$LATEST_WIDEVINE/manifest.json" ]; then
              $DRY_RUN_CMD echo "Found Widevine in Brave Nightly: $LATEST_WIDEVINE"
              if [ -z "''${DRY_RUN:-}" ]; then
                /usr/bin/sudo mkdir -p "$(dirname "$HELIUM_WIDEVINE")"
                /usr/bin/sudo cp -R "$LATEST_WIDEVINE" "$HELIUM_WIDEVINE"
                /usr/bin/sudo chown -R $(whoami):staff "$(dirname "$HELIUM_WIDEVINE")" 2>/dev/null || true
              fi
              $DRY_RUN_CMD echo "✓ Installed Widevine from Brave Browser Nightly to Helium"
              WIDEVINE_INSTALLED=true
            else
              $DRY_RUN_CMD echo "Brave Nightly found but Widevine not downloaded yet"
              $DRY_RUN_CMD echo "  → Open brave://settings/extensions and enable 'Widevine' under 'Google Widevine'"
              $DRY_RUN_CMD echo "  → Then run: just mac"
            fi
          fi

          # Fall back to Google Chrome if Brave didn't work
          if [ "$WIDEVINE_INSTALLED" = false ]; then
            CHROME_APP="/Applications/Google Chrome.app"
            CHROME_WIDEVINE="$CHROME_APP/Contents/Frameworks/Google Chrome Framework.framework/Libraries/WidevineCdm"

            if [ -d "$CHROME_APP" ] && [ -d "$CHROME_WIDEVINE" ]; then
              $DRY_RUN_CMD echo "Found Widevine in Google Chrome"
              if [ -z "''${DRY_RUN:-}" ]; then
                /usr/bin/sudo mkdir -p "$(dirname "$HELIUM_WIDEVINE")"
                /usr/bin/sudo cp -R "$CHROME_WIDEVINE" "$HELIUM_WIDEVINE"
                /usr/bin/sudo chown -R $(whoami):staff "$(dirname "$HELIUM_WIDEVINE")" 2>/dev/null || true
              fi
              $DRY_RUN_CMD echo "✓ Installed Widevine from Google Chrome to Helium"
              WIDEVINE_INSTALLED=true
            fi
          fi

          # If still not installed, show instructions
          if [ "$WIDEVINE_INSTALLED" = false ]; then
            $DRY_RUN_CMD echo "⚠ Widevine not found in Brave Nightly or Google Chrome"
            $DRY_RUN_CMD echo "To watch DRM content (Netflix, Prime Video, etc.) in Helium:"
            $DRY_RUN_CMD echo ""
            $DRY_RUN_CMD echo "Option 1 (Recommended): Install from Brave Nightly"
            $DRY_RUN_CMD echo "  1. Brave Nightly is already installed"
            $DRY_RUN_CMD echo "  2. Open Brave Nightly and go to: brave://settings/extensions"
            $DRY_RUN_CMD echo "  3. Enable 'Google Widevine' and let it download"
            $DRY_RUN_CMD echo "  4. Run: just mac"
            $DRY_RUN_CMD echo ""
            $DRY_RUN_CMD echo "Option 2: Install Google Chrome"
            $DRY_RUN_CMD echo "  1. Download from: https://www.google.com/chrome/"
            $DRY_RUN_CMD echo "  2. Install to /Applications"
            $DRY_RUN_CMD echo "  3. Run: just mac"
          fi
        fi
      fi
    fi
  '';
}
