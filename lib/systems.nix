{ lib, ... }:

rec {
  # Creates the hostname attrset given a hostname
  #
  # args:
  # hostname: hostname of the machine
  #
  # type:
  # genHostName :: String -> AttrSet
  genHostName = hostname: { config.networking.hostName = hostname; };

  # Imports home-manager config for each user, as well as the general home-manager NixOS module
  #
  # The args are passed in as an AttrSet
  #
  # args:
  # inputs: flake-level inputs, for use in the modules
  # users: list of users to import
  # src: base path of the flake
  #
  # type:
  # genHome :: AttrSet -> [AttrSet]
  genHome =
    {
      inputs,
      users,
      src,
      ...
    }:
    [ inputs.home-manager.nixosModules.home-manager ]
    ++ (map (user: { home-manager.users.${user} = import (src + "/users/${user}/home.nix"); }) users);

  # Imports password for each user via SOPS, as well as the general SOPS NixOS module
  #
  # The args are passed in as an AttrSet
  #
  # args:
  # inputs: flake-level inputs, for use in the modules
  # users: list of users to import
  # src: base path of the flake
  #
  # type:
  # genSops :: AttrSet -> [AttrSet]
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

  # Imports config for a given user
  #
  # args:
  # user: user to generate the config for
  # src: base path of the flake
  #
  # type:
  # importUser :: String -> Path -> (AttrSet -> AttrSet)
  importUser =
    user: src:
    {
      config,
      pkgs,
      lib,
      ...
    }@args:
    {
      users.users.${user} = import (src + "/users/${user}") (args // { name = user; });
    };

  # Imports the user configs for a list of users
  #
  # The args are passed in as an AttrSet
  #
  # args:
  # users: list of users to import
  # src: base path of the flake
  #
  # type:
  # genUsers :: AttrSet -> [AttrSet]
  genUsers = { users, src, ... }: (map (user: importUser user src) users);

  # Adds a config option for machines which are not x86_64-linux
  #
  # Note: the args are passed as an AttrSet for compatibility with genWrapper,
  # none of the args are actually used
  #
  # type:
  # genNonX86 :: AttrSet -> [AttrSet]
  genNonX86 =
    { ... }:
    [
      {
        config.nixpkgs = {
          config.allowUnsupportedSystem = true;
          buildPlatform = "x86_64-linux";
        };
      }
    ];

  # A wrapper for optionally generating configs based on arguments to constructSystem
  #
  # args:
  # cond: condition to generate based on
  # func: function to generate a module
  # args: inputs to the module described by func
  #
  # type:
  # genWrapper :: Boolean -> (AttrSet -> [AttrSet])
  genWrapper =
    cond: func: args:
    lib.optionals cond (func args);

  # Makes a custom NixOS system
  #
  # The args are passed in as an AttrSet
  #
  # args:
  # configPath: path to the folder containing hardware.nix & configuration.nix
  # hostname: hostname of the server
  # inputs: flake inputs to be used
  # src: base path of the repo
  # users: list of users to be added
  # home: enables home-manager on this machine (requires all users to have home-manager)
  # modules: list of machine-specific modules
  # server: determines if this machine is a server (true) or a PC (false)
  # sops: enables sops on this machine
  # system: the system architecture of the machine
  #
  # Adds extra common modules!
  # - SuperSandro2000's nixos-modules, for convenience functions and optional opinionated configs
  # - hardware.nix and configuration.nix, as one would expect for a typical setup
  # - the modules/ directory (check it out! most options can be overridden or are opt-in)
  # - convenience functions for SOPS, home-manager, user generation, and handling non-x86 machines
  #
  # type:
  # constructSystem :: AttrSet -> AttrSet
  constructSystem =
    {
      configPath,
      hostname,
      inputs,
      src,
      users,
      home ? true,
      modules ? [ ],
      # server ? true,
      sops ? true,
      system ? "x86_64-linux",
    }@args:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs server;
      };
      modules =
        [
          inputs.nixos-modules.nixosModule
          (genHostName hostname)
          (configPath + "/hardware.nix")
          (configPath + "/configuration.nix")
        ]
        ++ modules
        ++ (lib.rad-dev.fileList (src + "/modules"))
        ++ genWrapper sops genSops args
        ++ genWrapper home genHome args
        ++ genWrapper true genUsers args
        ++ genWrapper (system != "x86_64-linux") genNonX86 args;
    };

  # a convenience function for automatically generating NixOS systems by reading a directory via constructSystem
  #
  # Note: if you are only generating one system or there is no
  # folder/<hostname>/{default,configuration,hardware}.nix structure, you are
  # better off either directly invoking constructSystem or lib.nixosSystem
  #
  # args:
  # inputs: flake-inputs to be distributed to each system config
  # src: the base path to the repo
  # path: the path to read the systems from, should be a directory containing one directory per machine, each having at least the following
  #   - default.nix (with the extra params for constructSystem in it, see systems/palatine-hill/default.nix for an example)
  #   - hardware.nix
  #   - configuration.nix
  #
  # type:
  # genSystems :: AttrSet -> Path -> Path -> AttrSet
  genSystems =
    inputs: src: path:
    builtins.listToAttrs (
      map (
        name:
        let
          configPath = path + "/${name}";
        in
        {
          inherit name;
          value = constructSystem (
            {
              inherit inputs src configPath;
              hostname = name;
            }
            // import configPath { inherit inputs; }
          );
        }
      ) (lib.rad-dev.lsdir path)
    );
}
