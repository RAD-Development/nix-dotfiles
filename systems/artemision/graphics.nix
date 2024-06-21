{ pkgs, ... }:

{
  hardware.graphics = {
    ## radv: an open-source Vulkan driver from freedesktop
    enable = true;
    enable32Bit = true;

    ## amdvlk: an open-source Vulkan driver from AMD
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
      rocmPackages.clr.icd
    ];
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
}
