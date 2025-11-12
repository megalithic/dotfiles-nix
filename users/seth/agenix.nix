# Agenix secrets configuration for home-manager
# This file defines which secrets to decrypt and how to use them
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  # Define secrets to decrypt
  # Secrets will be decrypted to: ~/.config/agenix/<secret-name>

  # TODO: follow the secrets/README.md to add these
  # age.secrets = {
  #   # Environment variables (shell exports)
  #   env-vars = {
  #     file = ../../secrets/env-vars.age;
  #     # Optional: set custom path
  #     # path = "${config.home.homeDirectory}/.config/agenix/env-vars";
  #   };
  #
  #   # API keys (for scripts/applications)
  #   api-keys = {
  #     file = ../../secrets/api-keys.age;
  #   };
  #
  #   # GitHub token
  #   github-token = {
  #     file = ../../secrets/github-token.age;
  #   };
  #
  #   # Add more secrets as needed
  # };

  # Load secrets as environment variables in shell
  # This sources the env-vars secret file which should contain export statements
  # programs.zsh.initExtra = lib.mkAfter ''
  #   # Load agenix secrets as environment variables
  #   if [ -f "${config.age.secrets.env-vars.path}" ]; then
  #     source "${config.age.secrets.env-vars.path}"
  #   fi
  # '';

  # programs.fish.interactiveShellInit = lib.mkAfter ''
  #   # Load agenix secrets as environment variables
  #   if test -f "${config.age.secrets.env-vars.path}"
  #     source "${config.age.secrets.env-vars.path}"
  #   end
  # '';
  #
  # Make agenix CLI available
  home.packages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];
}
