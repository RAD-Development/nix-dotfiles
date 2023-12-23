{
  description = "NixOS configuration for RAD-Development Servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-index-database, sops-nix, ... }: {
    src = builtins.filterSource (path: type: type == "directory" || lib.hasSuffix ".nix" (baseNameOf path)) ./.;
    ls = dir: lib.attrNames (builtins.readDir (src + "/${dir}"));
    fileList = dir: map (file: ./. + "/${dir}/${file}") (ls dir);
    nixosConfigurations = let
      constructSystem = {
        hostname,
        system ? "x86_64-linux",
        modules ? [],
        users ? [],
      }: nixpkgs.lib.nixosSystem {
        inherit system hostname;
        modules = [
          sops-nix.nixosModules.sops
          nix-index-database.nixosModules.nix-index
          ./system/programs.nix
          ./system/configuration.nix
          ./system/${hostname}/configuration.nix
        ] ++ fileList "modules" ++ modules ++ map (user: ./users/${user}/default.nix ) users;
      };
    in {
      photon = constructSystem {
        hostname = "photon"
      };

      palatine-hill = constructSystem {
        hostname = "palatine-hill"
      };
    };
  };
}
