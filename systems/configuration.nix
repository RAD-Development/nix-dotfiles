{
  lib,
  pkgs,
  config,
  ...
}:
{
  security.auditd.enable = true;

  boot = {
    default = true;
    kernel.sysctl = {
      "net.ipv6.conf.ens3.accept_ra" = 1;
    };
  };

  networking = {
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = [ ];
    };
  };

  services = {
    fail2ban = {
      enable = lib.mkIf config.networking.firewall.enable (lib.mkDefault true);
      recommendedDefaults = true;
    };

    openssh = {
      enable = true;
      fixPermissions = true;
      extraConfig = "StreamLocalBindUnlink yes";

      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/etc/ssh/ssh_host_ecdsa_key";
          type = "ecdsa";
        }
      ];

      settings = {
        AllowAgentForwarding = "no";
        AllowTcpForwarding = "no";
        ChallengeResponseAuthentication = "no";
        ClientAliveCountMax = lib.mkDefault 2;
        Compression = "NO";
        IgnoreRhosts = "yes";
        LogLevel = lib.mkDefault "VERBOSE";
        MaxAuthTries = 3;
        MaxSessions = lib.mkDefault 2;
        PasswordAuthentication = false;
        PermitEmptyPasswords = "no";
        PermitRootLogin = "no";
        TcpKeepAlive = "no";
        X11Forwarding = lib.mkDefault false;
        KexAlgorithms = [
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group-exchange-sha256"
        ];

        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];

        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
          "hmac-sha2-512"
          "hmac-sha2-256"
          "umac-128@openssh.com"
        ];
      };
    };

    autopull = {
      enable = true;
      ssh-key = "/root/.ssh/id_ed25519_ghdeploy";
      path = /root/dotfiles;
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      flags = [ "--accept-flake-config" ];
      randomizedDelaySec = "1h";
      persistent = true;
      flake = "github:RAD-Development/nix-dotfiles";
    };
  };
}
