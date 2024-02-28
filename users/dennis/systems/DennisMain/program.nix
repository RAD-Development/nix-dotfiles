{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # CLI programs
    gource
    nvitop

    # Desktop programs
    teamspeak5_client
    # polymc-qt6

    # Games
    zeroad

    # Python packages
    python310Packages.torch-bin

    # Libraries
    cudaPackages.cudnn

    # Drivers
    cudatoolkit
  ];
}
