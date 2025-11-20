{
  config,
  lib,
  pkgs,
  ...
}: {
  # Install both Karabiner-Elements and the DriverKit component
  home.packages = with pkgs; [
    karabiner-elements
    karabiner-driverkit
  ];

  # Activation script to install DriverKit and Karabiner-Elements
  home.activation.installKarabinerElements = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Install DriverKit component first
    echo "[karabiner-elements] Installing DriverKit component..."
    ${pkgs.karabiner-driverkit}/bin/install-karabiner-driverkit

    # Symlink Karabiner-Elements.app to /Applications
    echo "[karabiner-elements] Setting up Karabiner-Elements.app..."
    KARABINER_APP="/Applications/Karabiner-Elements.app"
    KARABINER_NIX_APP="${pkgs.karabiner-elements}/Applications/Karabiner-Elements.app"

    if [ -e "$KARABINER_APP" ] && [ ! -L "$KARABINER_APP" ]; then
      echo "[karabiner-elements] Non-Nix Karabiner-Elements.app found, removing..."
      if [ -z "''${DRY_RUN:-}" ]; then
        rm -rf "$KARABINER_APP"
      fi
    fi

    if [ ! -e "$KARABINER_APP" ]; then
      echo "[karabiner-elements] Creating symlink to /Applications..."
      if [ -z "''${DRY_RUN:-}" ]; then
        ln -sf "$KARABINER_NIX_APP" "$KARABINER_APP"
        echo "[karabiner-elements] ✓ Symlinked Karabiner-Elements.app to /Applications"
      fi
    else
      echo "[karabiner-elements] ✓ Karabiner-Elements.app already linked"
    fi

    # Check if Karabiner-Elements is running
    if pgrep -q "karabiner_"; then
      echo "[karabiner-elements] Karabiner-Elements is currently running"
      echo "[karabiner-elements] You may need to restart it to apply changes"
    fi

    # Print post-installation instructions
    cat <<'EOF'

    ═══════════════════════════════════════════════════════════════════════════
    Karabiner-Elements Installation Complete
    ═══════════════════════════════════════════════════════════════════════════

    IMPORTANT: Manual Steps Required

    1. Open Karabiner-Elements from /Applications/
    2. Grant required permissions in System Settings:

       a) Privacy & Security > Input Monitoring
          - Enable: Karabiner-Core-Service
          - Enable: karabiner_grabber (if present)
          - Enable: karabiner_observer (if present)

       b) General > Login Items & Extensions
          - Keep Background Items enabled for:
            • Karabiner-Elements Non-Privileged Agents
            • Karabiner-Elements Privileged Daemons v2

       c) Login Items & Extensions > Driver Extensions
          - Approve: org.pqrs.Karabiner-DriverKit-VirtualHIDDevice

    3. Verify installation:
       - Open Karabiner-EventViewer
       - Check that input events are captured
       - Verify system extension shows [activated enabled]

    Configuration file: ~/.config/karabiner/karabiner.json

    Documentation: https://karabiner-elements.pqrs.org/docs/

    ═══════════════════════════════════════════════════════════════════════════

    EOF
  '';

  # Symlink Karabiner configuration if it exists
  home.file.".config/karabiner".source = lib.mkIf (builtins.pathExists ../karabiner) (
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles-nix/users/seth/karabiner"
  );
}
