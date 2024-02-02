{
  description = "NixOS configuration for RAD-Development Servers";

  nixConfig = {
    trusted-substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" "https://cache.alicehuston.xyz" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "cache.alicehuston.xyz:SJAm8HJVTWUjwcTTLAoi/5E1gUOJ0GWum2suPPv7CUo=%" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-fmt = {
      url = "github:rad-development/nixpkgs-fmt";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        fenix.follows = "fenix";
      };
    };

    nixos-modules = {
      url = "github:SuperSandro2000/nixos-modules";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-23_05.follows = "nixpkgs";
        nixpkgs-23_11.follows = "nixpkgs";
        utils.follows = "flake-utils";
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
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    nix-pre-commit = {
      url = "github:jmgilman/nix-pre-commit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs-fmt, home-manager, mailserver, nix-pre-commit, nixos-modules, nixpkgs, sops-nix, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = lib.genAttrs systems;

      src = builtins.filterSource (path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)) ./.;
      ls = dir: lib.attrNames (builtins.readDir (src + "/${dir}"));
      lsdir = dir: if (builtins.pathExists (src + "/${dir}")) then (lib.attrNames (lib.filterAttrs (path: type: type == "directory") (builtins.readDir (src + "/${dir}")))) else [ ];
      fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);

      recursiveMerge = attrList:
        let
          f = attrPath:
            builtins.zipAttrsWith (n: values:
              if builtins.tail values == [ ] then
                builtins.head values
              else if builtins.all builtins.isList values then
                builtins.unique (builtins.concatLists values)
              else if builtins.all builtins.isAttrs values then
                f (attrPath ++ [ n ]) values
              else
                lib.last values);
        in
        f [ ] attrList;

      config = {
        repos = [
          {
            repo = "https://gitlab.com/vojko.pribudic/pre-commit-update";
            rev = "bbd69145df8741f4f470b8f1cf2867121be52121";
            hooks = [{
              id = "pre-commit-update";
              args = [ "--dry-run" ];
            }];
          }
          {
            repo = "local";
            hooks = [
              {
                id = "nixfmt check";
                entry = "${nixpkgs-fmt.legacyPackages.x86_64-linux.nixpkgs-fmt}/bin/nixpkgs-fmt";
                args = [ "--check" ];
                language = "system";
                files = "\\.nix";
              }
              {
                id = "nix-flake-check";
                entry = "nix flake check";
                language = "system";
                files = "\\.nix";
                pass_filenames = false;
              }
            ];
          }
        ];
      };
    in
    {
      formatter = forEachSystem (system: nixpkgs-fmt.legacyPackages.${system}.nixpkgs-fmt);
      nixosConfigurations =
        let
          constructSystem = { hostname, users, home ? true, modules ? [ ], server ? true, sops ? true, system ? "x86_64-linux" }:
            lib.nixosSystem {
              inherit system;

              modules = [ nixos-modules.nixosModule sops-nix.nixosModules.sops { config.networking.hostName = "${hostname}"; } ] ++ (if server then [
                mailserver.nixosModules.mailserver
                ./systems/programs.nix
                ./systems/configuration.nix
                ./systems/${hostname}/hardware.nix
                ./systems/${hostname}/configuration.nix
              ] else [
                ./users/${builtins.head users}/systems/${hostname}/configuration.nix
                ./users/${builtins.head users}/systems/${hostname}/hardware.nix
              ]) ++ fileList "modules" ++ modules ++ lib.optional home home-manager.nixosModules.home-manager
                ++ (if home then (map (user: { home-manager.users.${user} = import ./users/${user}/home.nix; }) users) else [ ]) ++ map
                (user:
                  { config, lib, pkgs, ... }@args: {
                    users.users.${user} = import ./users/${user} (args // { name = "${user}"; });
                    boot.initrd.network.ssh.authorizedKeys = lib.mkIf server config.users.users.${user}.openssh.authorizedKeys.keys;
                    sops = lib.mkIf sops {
                      secrets."${user}/user-password" = {
                        sopsFile = ./users/${user}/secrets.yaml;
                        neededForUsers = true;
                      };
                    };
                  })
                users;
            };
        in
        (builtins.listToAttrs (map
          (system: {
            name = system;
            value = constructSystem ({ hostname = system; } // builtins.removeAttrs (import ./systems/${system} { }) [ "hostname" "server" "home" ]);
          })
          (lsdir "systems"))) // (builtins.listToAttrs (builtins.concatMap
          (user:
            map
              (system: {
                name = "${user}.${system}";
                value = constructSystem ({
                  hostname = system;
                  server = false;
                  users = [ user ];
                } // builtins.removeAttrs (import ./users/${user}/systems/${system} { }) [ "hostname" "server" "users" ]);
              })
              (lsdir "users/${user}/systems"))
          (lsdir "users")));

      devShell = lib.mapAttrs
        (system: sopsPkgs:
          with nixpkgs.legacyPackages.${system};
          mkShell {
            sopsPGPKeyDirs = [ "./keys" ];
            nativeBuildInputs = [ apacheHttpd sopsPkgs.sops-import-keys-hook ];
            packages = [ self.formatter.${system} ];
            shellHook = (nix-pre-commit.lib.${system}.mkConfig { inherit pkgs config; }).shellHook;
          })
        sops-nix.packages;

      hydraJobs = {
        build = (recursiveMerge
          (
            (map
              (machine: {
                ${machine.pkgs.system} = (builtins.listToAttrs (map
                  (pkg: {
                    name = pkg.name;
                    value = pkg;
                  })
                  machine.config.environment.systemPackages));
              })
              (builtins.attrValues self.nixosConfigurations)) ++ [
              (forEachSystem (system: {
                ${system}.${nixpkgs-fmt.legacyPackages.${system}.nixpkgs-fmt.name} = nixpkgs-fmt.legacyPackages.${system}.nixpkgs-fmt;
              }))
            ]
          ));
      };
    };
}
