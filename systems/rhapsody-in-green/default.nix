{ inputs, ... }:
{
  users = [ "richie" ];
  system = "x86_64-linux";
  home = true;
  sops = true;
  server = false;
  modules = [ inputs.nixos-hardware.nixosModules.framework-13-7040-amd ];
}
