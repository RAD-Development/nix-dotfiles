{ inputs, ... }:
{
  system = "x86_64-linux";
  home = true;
  sops = true;
  modules = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    { environment.systemPackages = [ inputs.wired-notify.packages.x86_64-linux.default ]; }
  ];
}
