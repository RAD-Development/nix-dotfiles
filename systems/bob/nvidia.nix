{ config, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
      nvidiaSettings = true;
    };
    nvidia-container-toolkit.enable = true;
  };
}
