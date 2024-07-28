{
  config,
  lib,
  pkgs,
  ...
}:
let
  hydra_notify_prometheus_port = "9199";
  hydra_queue_runner_prometheus_port = "9200";
in
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
      hydraURL = "https://hydra.alicehuston.xyz";
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
        <githubstatus>
          # check hosts and any declared checks
          jobs = (build-fork-hydra|nix-dotfiles-build):(pr-.*|branch-gh-readonly-queue-.*|branch-main):hosts
          context = ci/hydra: hosts
          inputs = nixexpr
          useShortContext = true
          excludeBuildFromContext = 1
        </githubstatus>
        <githubstatus>
          # check hosts and any declared checks
          jobs = (build-fork-hydra|nix-dotfiles-build):(pr-.*|branch-gh-readonly-queue-.*|branch-main):devChecks
          context = ci/hydra: checks
          inputs = nixexpr
          useShortContext = true
          excludeBuildFromContext = 1
        </githubstatus>
        Include ${config.sops.secrets."alice/gha-hydra-token".path}
        <hydra_notify>
          <prometheus>
            listen_address = 127.0.0.1
            port = ${hydra_notify_prometheus_port}
          </prometheus>
        </hydra_notify>
        queue_runner_metrics_address = 127.0.0.1:${hydra_queue_runner_prometheus_port}
      '';
    };

    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets."nix-serve/secret-key".path;
    };
    prometheus = {
      enable = true;
      webExternalUrl = "https://prom.alicehuston.xyz";
      port = 9001;
      exporters.node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
      scrapeConfigs = [
        {
          job_name = "palatine-hill";
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          ];
        }
        {
          job_name = "hydra-local";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${hydra_notify_prometheus_port}"
                "127.0.0.1:${hydra_queue_runner_prometheus_port}"
              ];
            }
          ];
        }
        {
          job_name = "hydra-external";
          scheme = "https";
          static_configs = [ { targets = [ "hydra.alicehuston.xyz" ]; } ];
        }
      ];
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
