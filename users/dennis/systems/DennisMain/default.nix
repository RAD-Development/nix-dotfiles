{ inputs, ... }:
{
  system = "x86_64-linux";
  home = false;
  sops = false;
  modules = [ inputs.nix-index-database.nixosModules.nix-index ];
}