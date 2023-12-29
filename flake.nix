{
  description = "NixOS configuration for RAD-Development Servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

  outputs = { nixpkgs, nixos-hardware, nixos-modules, home-manager, sops-nix, ... }:
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
              inherit system;

              modules = [
                nixos-modules.nixosModule
                home-manager.nixosModules.home-manager
                sops-nix.nixosModules.sops
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
              "richie"
              "alice"
              "dennis"
            ];
          };

          palatine-hill = constructSystem {
            hostname = "palatine-hill";
            users = [
              "richie"
              "alice"
              "dennis"
            ];
          };

          photon = constructSystem {
            hostname = "photon";
            users = [
              "richie"
              "alice"
              "dennis"
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
