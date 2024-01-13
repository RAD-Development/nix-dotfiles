{ pkgs, ... }:
{
  time.timeZone = "America/New_York";
  console.keyMap = "us";
  networking.hostId = "1beb3026";

  boot = {
    zfs.extraPools = [ "Main" ];
    filesystem = "zfs";
    useSystemdBoot = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      recommendedDefaults = true;
      logDriver = "local";
      daemon."settings" = {
        experimental = true;
        exec-opts = [ "native.cgroupdriver=systemd" ];
        log-opts = {
          max-size = "10m";
          max-file = "5";
        };
        data-root = "/var/lib/docker";
      };
      storageDriver = "overlay2";
    };

    podman = {
      enable = true;
      recommendedDefaults = true;
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  services = {
    nfs.server.enable = true;

    endlessh-go = {
      enable = true;
      port = 22;
    };

    openssh = {
      ports = [ 352 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        ChallengeResponseAuthentication = "no";
        AllowAgentForwarding = "no";
        AllowTcpForwarding = "no";
        TcpKeepAlive = "no";
        LogLevel = "VERBOSE";
      };
    };

    smartd.enable = true;

    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };

    zerotierone = {
      enable = true;
      joinNetworks = [ "e4da7455b2ae64ca" ];
    };
  };

  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}
