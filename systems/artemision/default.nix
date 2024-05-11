{ inputs, ... }:
{
  system = "x86_64-linux";
  home = true;
  sops = true;
  users = [ "alice" ];
  modules = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
    {
      environment.systemPackages = [
        inputs.wired-notify.packages.x86_64-linux.default
        inputs.hyprland-contrib.packages.x86_64-linux.grimblast
      ];
    }
  ];
}
