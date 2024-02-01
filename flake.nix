{
  description = "NixOS configuration for RAD-Development Servers";

  nixConfig = {
    trusted-substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" "https://cache.alicehuston.xyz" ];

    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" "cache.alicehuston.xyz:SJAm8HJVTWUjwcTTLAoi/5E1gUOJ0GWum2suPPv7CUo=%" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    systems = { url = "github:nix-systems/default"; };

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

  outputs = { self, home-manager, mailserver, nix-pre-commit, nixos-modules, nixpkgs, sops-nix, ... }:
    let
      inherit (nixpkgs) lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;

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
        in f [ ] attrList;

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
                id = "nixfmt";
                entry = "${nixpkgs.legacyPackages.x86_64-linux.nixfmt}/bin/nixfmt";
                args = [ "-w=200" "-c" ];
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
    in {
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
      nixosConfigurations = let
        constructSystem = { hostname, system ? "x86_64-linux", modules ? [ ], users ? [ "dennis" ] }:
          lib.nixosSystem {
            inherit system;

            modules = [
              mailserver.nixosModules.mailserver
              nixos-modules.nixosModule
              home-manager.nixosModules.home-manager
              sops-nix.nixosModules.sops
              ./systems/programs.nix
              ./systems/configuration.nix
              ./systems/${hostname}/hardware.nix
              ./systems/${hostname}/configuration.nix
              { config.networking.hostName = "${hostname}"; }
            ] ++ modules ++ fileList "modules" ++ map (user:
              { config, lib, pkgs, ... }@args: {
                users.users.${user} = import ./users/${user} (args // { name = "${user}"; });
                boot.initrd.network.ssh.authorizedKeys = config.users.users.${user}.openssh.authorizedKeys.keys;
                sops = {
                  secrets."${user}/user-password" = {
                    sopsFile = ./users/${user}/secrets.yaml;
                    neededForUsers = true;
                  };
                };
              }) users ++ map (user: { home-manager.users.${user} = import ./users/${user}/home.nix; }) users;
          };
      in (builtins.listToAttrs (map (system: {
        name = system;
        value = constructSystem { hostname = system; } // (import ./systems/${system} { });
      }) (lsdir "systems"))) // (builtins.listToAttrs (builtins.concatMap (user:
        map (system: rec {
          name = "${user}.${system}";
          cfg = import ./users/${user}/systems/${system} { };
          value = lib.nixosSystem {
            system = cfg.system ? "x86_64-linux";
            modules = [
              nixos-modules.nixosModule
              sops-nix.nixosModules.sops
              ./users/${user}/systems/${system}/configuration.nix
              ./users/${user}/systems/${system}/hardware.nix
              { config.networking.hostName = "${system}"; }
            ] ++ fileList "modules" ++ lib.optional (cfg.home-manager ? false) home-manager.nixosModules.home-manager;
          };
        }) (lsdir "users/${user}/systems")) (lsdir "users")));

      devShell = lib.mapAttrs (system: sopsPkgs:
        with nixpkgs.legacyPackages.${system};
        mkShell {
          sopsPGPKeyDirs = [ "./keys" ];
          nativeBuildInputs = [ apacheHttpd sopsPkgs.sops-import-keys-hook ];
          packages = [ self.formatter.${system} ];
          shellHook = (nix-pre-commit.lib.${system}.mkConfig { inherit pkgs config; }).shellHook;
        }) sops-nix.packages;

      hydraJobs = {
        build = (recursiveMerge (map (machine: {
          ${machine.pkgs.system} = (builtins.listToAttrs (map (pkg: {
            name = pkg.name;
            value = pkg;
          }) machine.config.environment.systemPackages));
        }) (builtins.attrValues self.nixosConfigurations)));
      };

    };
}
