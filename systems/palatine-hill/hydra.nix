{
  config,
  lib,
  pkgs,
  ...
}:

{
  systemd.services.hydra-notify.serviceConfig.EnvironmentFile =
    config.sops.secrets."hydra/environment".path;

  nix = {
    extraOptions = ''
      allowed-uris = github: gitlab: git+https:// git+ssh:// https://
      builders-use-substitutes = true
    '';

    buildMachines = [
      {
        hostName = "localhost";
        maxJobs = 2;
        protocol = "ssh-ng";
        speedFactor = 2;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "i686-linux"
        ];

        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
          "benchmark"
        ];
      }
    ];
  };

  services = {
    hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      smtpHost = "alicehuston.xyz";
      notificationSender = "hydra@alicehuston.xyz";
      gcRootsDir = "/ZFS/ZFS-primary/hydra";
      useSubstitutes = true;
      buildMachinesFiles = [ ];
      minimumDiskFree = 50;
      minimumDiskFreeEvaluator = 100;
      extraConfig = ''
        <git-input>
          timeout = 3600
        </git-input>
        Include ${config.sops.secrets."alice/gha-hydra-token".path}
      '';
    };

    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets."nix-serve/secret-key".path;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/E/y4UJQid6/0D9babh8l/3jTDJRXqZQ5rPcoxwm1j root@palatine-hill"
  ];

  users.users.hydra-queue-runner.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/E/y4UJQid6/0D9babh8l/3jTDJRXqZQ5rPcoxwm1j root@palatine-hill"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHtwvfXg/QFjMAjC4JRjlMAaGPgEfSyhpprNpqbGSJn hydra-queue-runner@palatine-hill"
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "hydra/environment".owner = "hydra";
      "nix-serve/secret-key".owner = "root";
      "alice/gha-hydra-token" = {
        sopsFile = ../../users/alice/secrets.yaml;
        owner = "hydra";
        group = "hydra";
        mode = "440";
      };
    };
  };
}
