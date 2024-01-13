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

  environment = {
    systemPackages = with pkgs; [
      docker-compose
    ];

    etc = {
      Creates /etc/lynis/custom.prf
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
      "login.defs" = {
        text = ''
          DEFAULT_HOME yes
          ENCRYPT_METHOD YESCRYPT
          GID_MAX 29999
          GID_MIN 1000
          SYS_GID_MAX 999
          SYS_GID_MIN 400
          SYS_UID_MAX 999
          SYS_UID_MIN 400
          TTYGROUP tty
          TTYPERM 0620
          UID_MAX 29999
          UID_MIN 1000
          UMASK 077
          PASS_MAX_DAYS	99999
          PASS_MIN_DAYS	0
          PASS_WARN_AGE	7
          SHA_CRYPT_MIN_ROUNDS 5000
          SHA_CRYPT_MAX_ROUNDS 5000

        '';
        mode = "0440";
      };
    };
  };


  security.auditd.enable = true;

  services = {
    nfs.server.enable = true;

    endlessh-go = {
      enable = true;
      port = 22;
    };

    openssh = {
      ports = [ 352 ];
      settings = {
        # not sure if this is needed
        ChallengeResponseAuthentication = "no";
      };
    };

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

  networking.firewall.enable = false;

  system.stateVersion = "23.05";
}
