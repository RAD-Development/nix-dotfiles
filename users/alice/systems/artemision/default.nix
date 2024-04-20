{ inputs, ... }:
{
  system = "x86_64-linux";
  home = true;
  sops = true;
  modules = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
    #({ pkgs, ... }: {
    #  nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    #  environment.systemPackages = [ rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
    #    extensions = [ "rust-src" "miri" "rust-analyzer" ];
    #  }) ];
    #})
    {
      environment.systemPackages = [
        inputs.wired-notify.packages.x86_64-linux.default
        inputs.hyprland-contrib.packages.x86_64-linux.grimblast
      ];
    }
  ];
}
