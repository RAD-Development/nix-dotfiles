{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.steam-run ];
  hardware.steam-hardware.enable = true;
  programs = {
    gamescope.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      gamescopeSession.enable = true;
      extest.enable = true;
    };
  };
}
