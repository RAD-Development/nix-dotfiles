{
  description = "NixOS configuration for RAD-Development Servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-modules = {
      url = "github:SuperSandro2000/nixos-modules";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-modules, nix-index-database, sops-nix, ... }:
  let
    inherit (nixpkgs) lib;
  in {
    nixosConfigurations = let
      constructSystem = {
        hostname,
        system ? "x86_64-linux",
        modules ? [],
        users ? [],
      }: lib.nixosSystem {
        inherit system;

        modules = [
          nixos-modules.nixosModule
          sops-nix.nixosModules.sops
          nix-index-database.nixosModules.nix-index
          ./systems/programs.nix
          ./systems/configuration.nix
          ./systems/${hostname}/configuration.nix
        ] ++ modules ++ map(user: ./users/${user}) users;

      };
    in {
      photon = constructSystem {
        hostname = "photon";
      };

      palatine-hill = constructSystem {
        hostname = "palatine-hill";
      };
    };
  };
}
