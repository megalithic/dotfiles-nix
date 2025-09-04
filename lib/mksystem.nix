# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs
, overlays
, inputs
,
}:

hostname:
{ arch
, username
, script ? null
, version ? "25.05"
, darwin ? false
,
}:

let
  pkgs = nixpkgs.legacyPackages.${arch};

  isDarwin = darwin;

  # True if Linux, which is a heuristic for not being Darwin.
  # isLinux = !isDarwin;

  # The config files for this system.
  machineConfig = ../machines/${hostname}.nix;
  userOSConfig = ../users/${username}/${if darwin then "darwin" else "nixos"}.nix;
  userHMConfig = ../users/${username}/home.nix;

  # NixOS vs nix-darwin functionst
  system = if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManager =
    if isDarwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  init =
    if (script != null) then pkgs.writeShellApplication { name = "init"; text = script; } else false;
in
system rec {
  inherit arch;

  modules = [
    # maybe run init scripts for a system
    (if init then { type = "app"; program = "${init}/bin/init"; } else { })

    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }

    # Allow unfree packages.
    { nixpkgs.config.allowUnfree = true; }

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    # https://nixos.org/manual/nixos/stable/index.html#sec-upgrading
    { system.stateVersion = if isDarwin then 5 else version; }

    machineConfig
    userOSConfig
    homeManager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import userHMConfig { inherit version; };
      home-manager.extraSpecialArgs = { inherit inputs; inherit username; inherit version; };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        currentSystemArch = arch;
        currentSystemHostname = hostname;
        currentSystemUsername = username;
        currentSystemVersion = version;

        inherit inputs;
        inherit system;
        inherit pkgs;
      };
    }
  ];
}
