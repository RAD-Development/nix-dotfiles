{
  description = "NixOS configuration for RAD-Development Servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    patch-bitwarden-directory-connector.url = "github:Silver-Golden/nixpkgs/bitwarden-directory-connector_pkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";

    nixos-modules = {
      url = "github:SuperSandro2000/nixos-modules";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
  };

  outputs = { nixpkgs, nixos-modules, home-manager, sops-nix, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      src = builtins.filterSource (path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)) ./.;
      ls = dir: lib.attrNames (builtins.readDir (src + "/${dir}"));
      fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);
    in
    {
      nixosConfigurations =
        let
          constructSystem =
            { hostname
            , system ? "x86_64-linux"
            , modules ? [ ]
            , users ? [ "dennis" ]
            ,
            }: lib.nixosSystem {
              inherit system lib;
              
              modules = [
                {
                  nixpkgs.overlays = [
                    (_self: super: {
                      bitwarden-directory-connector-cli = inputs.patch-bitwarden-directory-connector.legacyPackages.${system}.bitwarden-directory-connector-cli;
                    })
                  ];
                }
                nixos-modules.nixosModule
                home-manager.nixosModules.home-manager
                sops-nix.nixosModules.sops
                "${inputs.patch-bitwarden-directory-connector}/nixos/modules/services/security/bitwarden-directory-connector-cli.nix"
                ./systems/programs.nix
                ./systems/configuration.nix
                ./systems/${hostname}/hardware.nix
                ./systems/${hostname}/configuration.nix
                { config.networking.hostName = "${hostname}"; }
              ] ++ modules ++ fileList "modules"
              ++ map
                (user: { config, lib, pkgs, ... }@args: {
                  users.users.${user} = import ./users/${user} (args // { name = "${user}"; });
                  boot.initrd.network.ssh.authorizedKeys = config.users.users.${user}.openssh.authorizedKeys.keys;
                  sops = {
                    secrets."${user}/user-password" = {
                      sopsFile = ./users/${user}/secrets.yaml;
                      neededForUsers = true;
                    };
                  };
                })
                users
              ++ map (user: { home-manager.users.${user} = import ./users/${user}/home.nix; }) users;
            };
        in
        {
          jeeves-jr = constructSystem {
            hostname = "jeeves-jr";
            users = [
              "alice"
              "dennis"
              "richie"
            ];
          };

          palatine-hill = constructSystem {
            hostname = "palatine-hill";
            users = [
              "alice"
              "dennis"
              "richie"
            ];
          };

          photon = constructSystem {
            hostname = "photon";
            users = [
              "alice"
              "dennis"
              "richie"
            ];
          };
        };

      devShell = lib.mapAttrs
        (system: sopsPkgs:
          with nixpkgs.legacyPackages.${system};
          mkShell {
            sopsPGPKeyDirs = [ "./keys" ];
            nativeBuildInputs = [
              apacheHttpd
              sopsPkgs.sops-import-keys-hook
            ];
          }
        )
        sops-nix.packages;
    };
}
