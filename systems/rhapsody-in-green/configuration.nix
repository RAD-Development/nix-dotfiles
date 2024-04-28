{
  imports = [
    ../../users/richie/global/desktop.nix
    ../../users/richie/global/syncthing_base.nix
    ../../users/richie/global/zerotier.nix
    ./hardware.nix
  ];

  boot = {
    useSystemdBoot = true;
    default = true;
  };

  networking = {
    networkmanager.enable = true;
    hostId = "9b68eb32";
    firewall.enable = false;
  };

  hardware = {
    pulseaudio.enable = false;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  security.rtkit.enable = true;

  services = {
    autopull.enable = false;

    displayManager.sddm.enable = true;

    openssh.ports = [ 922 ];

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    syncthing.settings.folders = {
      "notes" = {
        id = "l62ul-lpweo"; # cspell:disable-line
        path = "/home/richie/notes";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "books" = {
        id = "6uppx-vadmy"; # cspell:disable-line
        path = "/home/richie/books";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "important" = {
        id = "4ckma-gtshs"; # cspell:disable-line
        path = "/home/richie/important";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "music" = {
        id = "vprc5-3azqc"; # cspell:disable-line
        path = "/home/richie/music";
        devices = [
          "bob"
          "phone"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
      "projects" = {
        id = "vyma6-lqqrz"; # cspell:disable-line
        path = "/home/richie/projects";
        devices = [
          "bob"
          "jeeves"
        ];
        fsWatcherEnabled = true;
      };
    };
  };

  services = {
    mongodb = {
      enable = true;
      dbpath = "/home/richie/mongodb";
      user = "richie";
    };
    # opensearch = {
    #   enable = true;
    #   user = "richie";
    #   group = "users";
    #   dataDir = "/home/richie/opensearch";
    #   settings ={
    #     "plugins.security.disabled"=true;
    #     "plugins.security.ssl.http.enabled"=false;
    #     "action.auto_create_index"=false;
    #     "bootstrap.memory_lock"=true;
    #   };
    # }; 
    elasticsearch = {
      enable = true;
    };
    graylog = {
      enable = true;
      passwordSecret = "LfjRKrrbONYDCvfD8gCNYqMzVAPHrxVBaw1oR3zIE73cF0EUaj8yEU4DsY8ADbwlGKCt0f2Q9Di8CN6JCYqGug2cfUwE9oNG";
      rootPasswordSha2 = "e3c652f0ba0b4801205814f8b6bc49672c4c74e25b497770bb89b22cdeb4e951";
      elasticsearchHosts = [ "http://localhost:9200" ];
      isMaster = true;
    };
    rsyslogd = {
      enable = true;
      extraConfig = "*.* @localhost:6514};RSYSLOG_SyslogProtocol23Format";
      # extraConfig = "*.* @${cfg.rsyslogServer};RSYSLOG_SyslogProtocol23Format";
    };
  };

  system.autoUpgrade.enable = false;
  system.stateVersion = "23.11";
}
