{ config, ... }:
{
  hardware = {
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;

    nvidia-container-toolkit.enable = true;
  };
}
