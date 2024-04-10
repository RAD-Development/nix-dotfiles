{ pkgs, ... }:
{

  networking = {
    hostId = "1beb3026";
    firewall.enable = false;
  };

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
      storageDriver = "overlay2";
      daemon."settings" = {
        experimental = true;
        data-root = "/var/lib/docker";
        exec-opts = [ "native.cgroupdriver=systemd" ];
        log-opts = {
          max-size = "10m";
          max-file = "5";
        };
      };
    };

    podman = {
      enable = true;
      recommendedDefaults = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [ docker-compose ];
    etc = {
      # Creates /etc/lynis/custom.prf
      "lynis/custom.prf" = {
        text = ''
          skip-test=BANN-7126
          skip-test=BANN-7130
          skip-test=DEB-0520
          skip-test=DEB-0810
          skip-test=FIRE-4513
          skip-test=HRDN-7222
          skip-test=KRNL-5820
          skip-test=LOGG-2190
          skip-test=LYNIS
          skip-test=TOOL-5002
        '';
        mode = "0440";
      };
    };
  };

  services = {
    nfs.server.enable = true;

    openssh.ports = [ 352 ];

    smartd.enable = true;

    sysstat.enable = true;

    usbguard = {
      enable = true;
      rules = ''
        allow id 1532:0241
      '';
    };

    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };

    zerotierone = {
      enable = true;
      joinNetworks = [ "e4da7455b2ae64ca" ];
    };
  };

  system.stateVersion = "23.05";
}
