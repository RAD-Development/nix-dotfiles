{
  description = "NixOS configuration for RAD-Development Servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    systems = {
      url = "github:nix-systems/default";
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

  outputs =
    { home-manager
    , mailserver
    , nix-pre-commit
    , nixos-modules
    , nixpkgs
    , sops-nix
    , ...
    }:
    let
      inherit (nixpkgs) lib;
      src = builtins.filterSource (path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)) ./.;
      ls = dir: lib.attrNames (builtins.readDir (src + "/${dir}"));
      lsdir = dir: if (builtins.pathExists (src + "/${dir}")) then (lib.attrNames (lib.filterAttrs (path: type: type == "directory") (builtins.readDir (src + "/${dir}")))) else [ ];
      fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);

      config = {
        repos = [
          {
            repo = "https://gitlab.com/vojko.pribudic/pre-commit-update";
            rev = "f4886322eb7fc53c49e28cc1991674deb1f790bd";
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
              {
                id = "nixpkgs-fmt check";
                entry = "${nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt}/bin/nixpkgs-fmt";
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
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      nixosConfigurations =
        let
          constructSystem =
            { hostname
            , users
            , home ? true
            , modules ? [ ]
            , server ? true
            , sops ? true
            , system ? "x86_64-linux"
            }: lib.nixosSystem {
              inherit system;

              modules = [
                nixos-modules.nixosModule
                sops-nix.nixosModules.sops
                { config.networking.hostName = "${hostname}"; }
              ] ++ (if server then [
                mailserver.nixosModules.mailserver
                ./systems/programs.nix
                ./systems/configuration.nix
                ./systems/${hostname}/hardware.nix
                ./systems/${hostname}/configuration.nix
              ] else [
                ./users/${builtins.head users}/systems/${hostname}/configuration.nix
                ./users/${builtins.head users}/systems/${hostname}/hardware.nix
              ]) ++ fileList "modules"
              ++ modules
              ++ lib.optional home home-manager.nixosModules.home-manager
              ++ (if home then (map (user: { home-manager.users.${user} = import ./users/${user}/home.nix; }) users) else [ ])
              ++ map
                (user: { config, lib, pkgs, ... }@args: {
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
          (lsdir "systems"))) //
        (builtins.listToAttrs (builtins.concatMap
          (user: map
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
            nativeBuildInputs = [
              apacheHttpd
              sopsPkgs.sops-import-keys-hook
            ];

            shellHook = (nix-pre-commit.lib.${system}.mkConfig {
              inherit pkgs config;
            }).shellHook;
          }
        )
        sops-nix.packages;
    };
}
