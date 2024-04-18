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

    nixos-hardware-fw16 = {
      url = "git+https://github.com/jkoking/nixos-hardware?ref=add-framework-16";
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

      inherit (nixpkgs) lib;
      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSystem = lib.genAttrs systems;
      overlayList = [
        #self.overlays.default
        nix.overlays.default
      ];
      pkgsBySystem = forEachSystem (
        system:
        import nixpkgs {
          inherit system;
          overlays = overlayList;
          config = {
            allowUnfree = true;
            isHydra = true;
          };
        }
      );

      src = builtins.filterSource (
        path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)
      ) ./.;
      ls = dir: lib.attrNames (builtins.readDir (src + "/${dir}"));
      lsdir =
        dir:
        if (builtins.pathExists (src + "/${dir}")) then
          (lib.attrNames (
            lib.filterAttrs (path: type: type == "directory") (builtins.readDir (src + "/${dir}"))
          ))
        else
          [ ];
      fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);


      config = {
        repos = [
          {
            repo = "https://gitlab.com/vojko.pribudic/pre-commit-update";
            rev = "d068467ebed445e110f4012204bfd2816c3c01ee";
            hooks = [
              {
                id = "pre-commit-update";
                args = [ "--dry-run" ];
              }
            ];
          }
          {
            repo = "local";
            hooks = [
              # {
              #   id = "nixfmt check";
              #   entry = "${nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style}/bin/nixfmt";
              #   args = [ "--check" ];
              #   language = "system";
              #   files = "\\.nix";
              # }
              # {
              #   id = "check";
              #   entry = "nix eval";
              #   language = "system";
              #   files = "\\.nix";
              #   pass_filenames = false;
              # }
            ];
          }
        ];
      };
    in
    {
      inherit (self) outputs;
      hydraJobs = import ./hydra.nix { inherit inputs outputs; };

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
              modules =
                [
                  nixos-modules.nixosModule
                  sops-nix.nixosModules.sops
                  { config.networking.hostName = "${hostname}"; }
                ]
                ++ (
                  if server then
                    [
                      ./systems/configuration.nix
                      ./systems/${hostname}/hardware.nix
                      ./systems/${hostname}/configuration.nix
                    ]
                  else
                    [
                      ./users/${builtins.head users}/systems/${hostname}/configuration.nix
                      ./users/${builtins.head users}/systems/${hostname}/hardware.nix
                    ]
                )
                ++ fileList "modules"
                ++ modules
                ++ lib.optional home home-manager.nixosModules.home-manager
                ++ lib.optional (builtins.elem "minimal" iso) "${toString nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                ++ lib.optional (builtins.elem "sd" iso) "${toString nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
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
          }) (lsdir "systems")
        ))
        // (builtins.listToAttrs (
          builtins.concatMap (
            user:
            map (system: {
              name = "${user}.${system}";
              value = constructSystem (
                {
                  hostname = system;
                  server = false;
                  users = [ user ];
                }
                // builtins.removeAttrs (import ./users/${user}/systems/${system} { inherit inputs; }) [
                  "hostname"
                  "server"
                  "users"
                ]
              );
            }) (lsdir "users/${user}/systems")
          ) (lsdir "users")
        ));

      devShell = lib.mapAttrs (
        system: sopsPkgs:
        with nixpkgs.legacyPackages.${system};
        mkShell {
          sopsPGPKeyDirs = [ "./keys" ];
          nativeBuildInputs = [
            apacheHttpd
            sopsPkgs.sops-import-keys-hook
          ];
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
