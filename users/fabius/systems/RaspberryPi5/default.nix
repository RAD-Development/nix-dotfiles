{ inputs, ... }:
{
  system = "aarch64-linux";
  iso = true;
  home = false;
  sops = false;
  modules = [ inputs.nix-index-database.nixosModules.nix-index ];
}
