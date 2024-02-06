{ inputs, ... }:
{
  system = "aarch64-linux";
  iso = [ "sd" ];
  home = false;
  sops = false;
  modules = [ inputs.nix-index-database.nixosModules.nix-index ];
}
