{ lib, ... }:

rec {
  genHostName = hostname: { config.networking.hostName = hostname; };

  genHome =
    {
      inputs,
      users,
      src,
      ...
    }:
    [ inputs.home-manager.nixosModules.home-manager ]
    ++ (map (user: { home-manager.users.${user} = import (src + "/users/${user}/home.nix"); }) users);

  genSops =
    {
      inputs,
      users,
      src,
      ...
    }:
    [ inputs.sops-nix.nixosModules.sops ]
    ++ (map (user: {
      sops.secrets."${user}/user-password" = {
        sopsFile = src + "/users/${user}/secrets.yaml";
        neededForUsers = true;
      };
    }) users);

  importUser =
    user: src:
    {
      config,
      lib,
      pkgs,
      ...
    }@args:
    {
      users.users.${user} = import (src + "/users/${user}") (args // { name = user; });
    };

  genUsers = { users, src, ... }: (map (user: importUser user src) users);

  genNonX86 =
    { ... }:
    {
      config.nixpkgs = {
        config.allowUnsupportedSystem = true;
        buildPlatform = "x86_64-linux";
      };
    };

  genWrapper =
    var: func: args:
    lib.optionals var (func args);

  constructSystem =
    {
      hostname,
      users,
      inputs,
      src,
      home ? true,
      iso ? [ ],
      modules ? [ ],
      server ? true,
      sops ? true,
      system ? "x86_64-linux",

    }@args:

    lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        [
          inputs.nixos-modules.nixosModule
          (genHostName hostname)
          (src + "/systems/${hostname}/hardware.nix")
          (src + "/systems/${hostname}/configuration.nix")
        ]
        ++ modules
        ++ (lib.rad-dev.fileList (src + "/modules"))
        ++ genWrapper sops genSops args
        ++ genWrapper home genHome args
        ++ genWrapper true genUsers args
        ++ genWrapper (system != "x86_64-linux") genNonX86 args;
    };

  genSystems =
    inputs: src: path:
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = constructSystem (
          {
            inherit inputs src;
            hostname = name;
          }
          // import (path + "/${name}") { inherit inputs; }
        );
      }) (lib.rad-dev.lsdir path)
    );
}
