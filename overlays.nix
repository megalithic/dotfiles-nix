# Re-export from overlays/default.nix
# This file exists for backward compatibility with flake.nix
{
  inputs,
  lib,
  ...
}:
  import ./overlays {inherit inputs lib;}
