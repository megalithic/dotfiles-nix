{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.karabiner-elements-nix;
  karabinerPkg = cfg.package;
  driverPkg = karabinerPkg.driver;

  # Paths within the packages
  driverSupportPath = "${driverPkg}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice";
  driverManagerApp = "${driverPkg}/Applications/.Karabiner-VirtualHIDDevice-Manager.app";
  karabinerSupportPath = "${karabinerPkg}/Library/Application Support/org.pqrs/Karabiner-Elements";

  # System paths
  systemDriverPath = "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice";
  systemKarabinerPath = "/Library/Application Support/org.pqrs/Karabiner-Elements";
  nixKarabinerApps = "/Applications/.Nix-Karabiner";
in {
  # Use a different name to avoid conflict with built-in nix-darwin module
  # which is broken for Karabiner-Elements v15+
  options.services.karabiner-elements-nix = with types; {
    enable = mkEnableOption "Karabiner-Elements keyboard customizer for macOS (custom module for v15+)";

    package = mkOption {
      type = package;
      default = pkgs.karabiner-elements;
      defaultText = literalExpression "pkgs.karabiner-elements";
      description = "The karabiner-elements package to use.";
    };
  };

  config = mkIf cfg.enable {
    # Pre-activation: Install DriverKit components
    system.activationScripts.preActivation.text = ''
      echo "[karabiner-elements] Setting up Karabiner DriverKit..."

      # Create directories
      mkdir -p "${nixKarabinerApps}"
      mkdir -p "/Library/Application Support/org.pqrs"

      # Copy DriverKit support files (VirtualHIDDevice-Daemon, scripts, etc.)
      if [ -d "${driverSupportPath}" ]; then
        echo "[karabiner-elements] Installing DriverKit VirtualHIDDevice..."
        rm -rf "${systemDriverPath}"
        cp -R "${driverSupportPath}" "/Library/Application Support/org.pqrs/"
        chmod -R 755 "${systemDriverPath}"
        chown -R root:wheel "${systemDriverPath}"
      else
        echo "[karabiner-elements] WARNING: DriverKit support path not found at ${driverSupportPath}"
      fi

      # Copy VirtualHIDDevice-Manager app (needed for system extension activation)
      if [ -d "${driverManagerApp}" ]; then
        echo "[karabiner-elements] Installing VirtualHIDDevice-Manager..."
        rm -rf "${nixKarabinerApps}/.Karabiner-VirtualHIDDevice-Manager.app"
        cp -R "${driverManagerApp}" "${nixKarabinerApps}/"
        chmod -R 755 "${nixKarabinerApps}/.Karabiner-VirtualHIDDevice-Manager.app"
      else
        echo "[karabiner-elements] WARNING: VirtualHIDDevice-Manager not found at ${driverManagerApp}"
      fi

      # Copy Karabiner-Elements support files (binaries, agents, daemons)
      if [ -d "${karabinerSupportPath}" ]; then
        echo "[karabiner-elements] Installing Karabiner-Elements support files..."
        rm -rf "${systemKarabinerPath}"
        cp -R "${karabinerSupportPath}" "/Library/Application Support/org.pqrs/"
        chmod -R 755 "${systemKarabinerPath}"
        chown -R root:wheel "${systemKarabinerPath}"

        # Set suid on session monitor (required for proper permissions)
        if [ -f "${systemKarabinerPath}/bin/karabiner_session_monitor" ]; then
          chmod 4755 "${systemKarabinerPath}/bin/karabiner_session_monitor"
          echo "[karabiner-elements] Set suid on karabiner_session_monitor"
        fi
      else
        echo "[karabiner-elements] WARNING: Karabiner-Elements support path not found at ${karabinerSupportPath}"
      fi

      # Symlink Karabiner-Elements.app to /Applications
      KARABINER_APP="/Applications/Karabiner-Elements.app"
      KARABINER_NIX_APP="${karabinerPkg}/Applications/Karabiner-Elements.app"
      if [ -d "$KARABINER_NIX_APP" ]; then
        if [ -e "$KARABINER_APP" ] && [ ! -L "$KARABINER_APP" ]; then
          echo "[karabiner-elements] Removing existing non-Nix Karabiner-Elements.app..."
          rm -rf "$KARABINER_APP"
        fi
        if [ ! -e "$KARABINER_APP" ]; then
          ln -sf "$KARABINER_NIX_APP" "$KARABINER_APP"
          echo "[karabiner-elements] Symlinked Karabiner-Elements.app to /Applications"
        fi
      fi

      # Symlink Karabiner-EventViewer.app to /Applications
      EVENTVIEWER_APP="/Applications/Karabiner-EventViewer.app"
      EVENTVIEWER_NIX_APP="${karabinerPkg}/Applications/Karabiner-EventViewer.app"
      if [ -d "$EVENTVIEWER_NIX_APP" ]; then
        if [ -e "$EVENTVIEWER_APP" ] && [ ! -L "$EVENTVIEWER_APP" ]; then
          rm -rf "$EVENTVIEWER_APP"
        fi
        if [ ! -e "$EVENTVIEWER_APP" ]; then
          ln -sf "$EVENTVIEWER_NIX_APP" "$EVENTVIEWER_APP"
          echo "[karabiner-elements] Symlinked Karabiner-EventViewer.app to /Applications"
        fi
      fi
    '';

    # Post-activation: Activate system extension and start services
    system.activationScripts.postActivation.text = ''
      echo "[karabiner-elements] Post-activation setup..."

      # Create log files
      for logfile in /var/log/{karabiner-virtualhid,karabiner-virtualhid-error}.log; do
        if [ ! -f "$logfile" ]; then
          touch "$logfile"
          chmod 644 "$logfile"
          chown root:wheel "$logfile"
        fi
      done

      # Check if system extension is already activated and approved
      SYSEXT_STATUS=$(systemextensionsctl list 2>/dev/null | grep -i "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice" || true)
      if echo "$SYSEXT_STATUS" | grep -q "activated enabled"; then
        echo "[karabiner-elements] System extension already activated and approved"
      elif [ -n "$SYSEXT_STATUS" ]; then
        echo "[karabiner-elements] System extension registered but needs approval: $SYSEXT_STATUS"
        echo "[karabiner-elements] NOTE: Approve in System Settings > Privacy & Security > Security"
      else
        echo "[karabiner-elements] System extension not registered. Requesting activation..."
        # Activate the system extension (use timeout to avoid blocking if it waits for user)
        if [ -x "${nixKarabinerApps}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" ]; then
          timeout 5 "${nixKarabinerApps}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate 2>/dev/null || true
          echo "[karabiner-elements] System extension activation requested"
          echo "[karabiner-elements] NOTE: Approve in System Settings > Privacy & Security > Security"
        fi
      fi

      cat <<'EOF'

    ═══════════════════════════════════════════════════════════════════════════
    Karabiner-Elements Setup
    ═══════════════════════════════════════════════════════════════════════════

    If this is a fresh install, you may need to:

    1. Approve the system extension in System Settings:
       Privacy & Security > Security > "System software from ... was blocked"
       Click "Allow"

    2. Grant Input Monitoring permissions in System Settings:
       Privacy & Security > Privacy > Input Monitoring
       Enable: karabiner_grabber, karabiner_observer

    3. Restart your Mac after approving the system extension

    Configuration file: ~/.config/karabiner/karabiner.json

    ═══════════════════════════════════════════════════════════════════════════

EOF
    '';

    # Launch daemon for VirtualHIDDevice-Daemon
    launchd.daemons.karabiner-virtualhid-daemon = {
      serviceConfig = {
        Label = "org.pqrs.Karabiner-DriverKit-VirtualHIDDeviceClient";
        UserName = "root";
        GroupName = "wheel";
        KeepAlive = {
          SuccessfulExit = false;
          AfterInitialDemand = true;
        };
        RunAtLoad = true;
        StandardOutPath = "/var/log/karabiner-virtualhid.log";
        StandardErrorPath = "/var/log/karabiner-virtualhid-error.log";
        Program = "${systemDriverPath}/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
        WorkingDirectory = "/tmp";
        ThrottleInterval = 30;
        Nice = -20;
      };
    };

    # Launch daemon for Karabiner privileged daemons
    launchd.daemons.karabiner-core-service = {
      serviceConfig = {
        Label = "org.pqrs.service.daemon.Karabiner-Core-Service";
        UserName = "root";
        GroupName = "wheel";
        KeepAlive = true;
        RunAtLoad = true;
        Program = "${systemKarabinerPath}/Karabiner-Core-Service.app/Contents/MacOS/Karabiner-Core-Service";
        WorkingDirectory = "/tmp";
        ThrottleInterval = 30;
      };
    };

    # User agents are handled by Karabiner-Elements.app itself when launched
    # The app registers its own login items for:
    # - Karabiner-Elements Non-Privileged Agents
    # - Karabiner-Elements Privileged Daemons
  };
}
