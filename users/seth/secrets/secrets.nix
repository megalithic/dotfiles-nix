# REF:
# https://github.com/ryantm/agenix?tab=readme-ov-file#using-agenix-with-home-manager
# https://github.com/ryantm/agenix?tab=readme-ov-file#tutorial
# https://github.com/mhanberg/.dotfiles/blob/main/nix/home/secrets.nix
let
  megabookpro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIct9+vYP4qH+00TY915Nj5D3YzPcomQEkB+ffjQ5fl";
  systems = [ megabookpro ];
in
{
  "./repo_access.age".publicKeys = systems;
  #   "armored-secret.age" = {
  #     publicKeys = [ user1 ];
  #     armor = true;
  #   };
}

