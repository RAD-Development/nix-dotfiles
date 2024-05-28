{ pkgs, ... }:
{
  imports = [
    ../../users/richie/global/zerotier.nix
    ./docker
  ];

  networking = {
    hostId = "1beb3026";
    firewall.enable = false;
  };

  boot = {
    zfs.extraPools = [ "Main" ];
    filesystem = "zfs";
    useSystemdBoot = true;
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
      autoSnapshot = {
        enable = true;
        frequent = 8;
      };
    };
  };

  system.stateVersion = "23.05";
}
