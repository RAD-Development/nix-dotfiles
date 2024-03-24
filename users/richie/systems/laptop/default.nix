{ inputs, ... }:
{
  system = "x86_64-linux";
  home = true;
  sops = true;
  modules = [
    inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
  ];
}
