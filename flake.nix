{
  description = "NixOS configuration for RAD-Development Servers";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org/?priority=1&want-mass-query=true"
      "https://attic.alicehuston.xyz/cache-nix-dot?priority=4&want-mass-query=true"
      "https://cache.alicehuston.xyz/?priority=5&want-mass-query=true"
      "https://nix-community.cachix.org/?priority=10&want-mass-query=true"
    ];
    trusted-substituters = [
      "https://cache.nixos.org"
      "https://attic.alicehuston.xyz/cache-nix-dot"
      "https://cache.alicehuston.xyz"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.alicehuston.xyz:SJAm8HJVTWUjwcTTLAoi/5E1gUOJ0GWum2suPPv7CUo=%"
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache-nix-dot:0hp/F6mUJXNyZeLBPNBjmyEh8gWsNVH+zkuwlWMmwXg="
    ];
    trusted-users = [ "root" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    systems.url = "github:nix-systems/default";
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix = {
      url = "github:NixOS/nix/latest-release";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-modules = {
      url = "github:SuperSandro2000/nixos-modules";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs-stable";
      };
    };

    nix-pre-commit = {
      url = "github:jmgilman/nix-pre-commit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    wired-notify = {
      url = "github:Toqozz/wired-notify";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    attic = {
      url = "github:zhaofengli/attic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nix,
      home-manager,
      nix-pre-commit,
      nixos-hardware,
      nixos-modules,
      nixpkgs,
      sops-nix,
      wired-notify,
      ...
    }@inputs:
    let

      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSystem = lib.genAttrs systems;

      # filter out all non-nix files and returns the nix-store path
      # (ie. git configs, git refs, etc)
      #
      # used for module imports and system search
      src = builtins.filterSource (
        path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)
      ) ./.;

      config = {
        repos = [
          {
            repo = "local";
            hooks = [
              {
                id = "nix fmt check";
                entry = "${outputs.formatter.x86_64-linux}/bin/nixfmt";
                args = [ "--check" ];
                language = "system";
                files = "\\.nix";
              }
            ];
          }
        ];
      };

      # adds our lib functions to lib namespace
      lib = nixpkgs.lib.extend (
        self: super:
        import ./lib {
          inherit nixpkgs inputs;
          lib = self;
        }
      );
    in
    {
      inherit (self) outputs;

      hydraJobs = import ./hydra/jobs.nix { inherit inputs outputs; };
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      nixosConfigurations =
        let
          constructSystem =
            {
              hostname,
              users,
              home ? true,
              iso ? [ ],
              modules ? [ ],
              server ? true,
              sops ? true,
              system ? "x86_64-linux",
            }:
            lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = inputs;
              modules =
                [
                  nixos-modules.nixosModule
                  sops-nix.nixosModules.sops
                  { config.networking.hostName = "${hostname}"; }
                  ./systems/${hostname}/hardware.nix
                  ./systems/${hostname}/configuration.nix
                ]
                ++ (lib.rad-dev.fileList src "modules")
                ++ modules
                ++ lib.optional home home-manager.nixosModules.home-manager
                ++ (
                  if home then
                    (map (user: { home-manager.users.${user} = import ./users/${user}/home.nix; }) users)
                  else
                    [ ]
                )
                ++ lib.optional (system != "x86_64-linux") {
                  config.nixpkgs = {
                    config.allowUnsupportedSystem = true;
                    buildPlatform = "x86_64-linux";
                  };
                }
                ++ map (
                  user:
                  {
                    config,
                    lib,
                    pkgs,
                    ...
                  }@args:
                  {
                    users.users.${user} = import ./users/${user} (args // { name = "${user}"; });
                    boot.initrd.network.ssh.authorizedKeys =
                      lib.mkIf server
                        config.users.users.${user}.openssh.authorizedKeys.keys;
                    sops = lib.mkIf sops {
                      secrets."${user}/user-password" = {
                        sopsFile = ./users/${user}/secrets.yaml;
                        neededForUsers = true;
                      };
                    };
                  }
                ) users;
            };
        in
        (builtins.listToAttrs (
          map (system: {
            name = system;
            value = constructSystem (
              {
                hostname = system;
              }
              // builtins.removeAttrs (import ./systems/${system} { inherit inputs; }) [
                "hostname"
                "server"
                "home"
              ]
            );
          }) (lib.rad-dev.lsdir src "systems")

        ));

      devShell = lib.mapAttrs (
        system: sopsPkgs:
        with nixpkgs.legacyPackages.${system};
        mkShell {
          sopsPGPKeyDirs = [ "./keys" ];
          nativeBuildInputs = [ sopsPkgs.sops-import-keys-hook ];
          packages = [
            self.formatter.${system}
            nixpkgs.legacyPackages.${system}.deadnix
            nixpkgs.legacyPackages.${system}.treefmt
            nixpkgs.legacyPackages.${system}.pre-commit
          ];
          shellHook = (nix-pre-commit.lib.${system}.mkConfig { inherit pkgs config; }).shellHook;
        }
      ) sops-nix.packages;
    };
}
