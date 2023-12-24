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
  };

  outputs = { nixpkgs, nixos-modules, sops-nix, ... }:
  let
    inherit (nixpkgs) lib;
    src = builtins.filterSource (path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)) ./.;
    ls = dir: lib.attrNames (builtins.readDir (src + "/${dir}"));
    fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);
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
          ./systems/programs.nix
          ./systems/configuration.nix
          ./systems/${hostname}/hardware.nix
          ./systems/${hostname}/configuration.nix
        ] ++ modules ++ fileList "modules" ++ map(user: ./users/${user}) users;

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
