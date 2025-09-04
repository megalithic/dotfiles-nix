# Nix Configuration Guide

## Commands

- **Update system**: `darwin-rebuild switch --flake .#goose` (macOS) or `home-manager switch --flake .#nixos` (Linux)
- **Check configuration**: `nix flake check --no-build --all-systems`
- **Format code**: `nix fmt` (uses nixfmt-rfc-style)
- **Add packages**: Edit relevant configuration files and rebuild
- **Test a module**: Temporarily add/modify in configuration, then rebuild to test

## Code Style

- **Formatting**: Two spaces for indentation, follow nixfmt-rfc-style conventions
- **Module structure**: Use `hm.<module_name>` namespace to avoid conflicts with built-in modules
- **Options naming**: Use descriptive names with camelCase (e.g., `enable`, `extraConfig`)
- **Default values**: Set sensible defaults using `default = value` or `// { default = value; }`
- **Conditionals**: Use `mkIf config.name.enable { ... }` for conditional configurations
- **Imports**: Group imports at the top; use relative paths when possible
- **Documentation**: Add comments for non-obvious configurations or behaviors
- **Platform-specific code**: Use `pkgs.stdenv.is<Platform>` for platform checks
- **Whitespace**: No trailing spaces at end of lines

## Organization

- Machine-specific configs in `/machines/<hostname>.nix`
- Operating System-specific configs in `/users/<username>/<darwin|nixos|linux|wsl>.nix`
- User-specific configs in `/users/<username>/`
- Primary user's home-manager config at `/users/<username>/home.nix`
- Related user's home-manager modules in `/users/<username>/<module_name>.nix`
