{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      jeeves = {
        hostname = "192.168.90.40";
        user = "richie";
        identityFile = "~/.ssh/id_ed25519";
        port = 629;
      };
      jeevesjr = {
        hostname = "192.168.90.35";
        user = "richie";
        identityFile = "~/.ssh/id_ed25519";
        port = 352;
      };
      bob = {
        hostname = "192.168.90.25";
        user = "richie";
        identityFile = "~/.ssh/id_ed25519";
        port = 262;
      };
    };
  };
}
