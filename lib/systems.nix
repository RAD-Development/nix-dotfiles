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

  genUsers =
    { users, src, ... }:
    (map (
      user:
      {
        config,
        lib,
        pkgs,
        ...
      }@args:
      {
        users.users.${user} = import (src + "/users/${user}") (args // { name = user; });
      }
    ) users);

  genWrapper =
    var: func: args:
    lib.optionals var (func args);

  nonX86 = {
    config.nixpkgs = {
      config.allowUnsupportedSystem = true;
      buildPlatform = "x86_64-linux";
    };
  };

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
        ++ (lib.rad-dev.fileList src "modules")
        ++ genWrapper sops genSops args
        ++ genWrapper home genHome args
        ++ genWrapper true genUsers args;
    };
}
