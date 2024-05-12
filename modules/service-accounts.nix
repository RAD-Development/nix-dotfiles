{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.rad-dot.service-accounts;
  service-account-type = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "service account ${cfg.account-name}";

      # default value gets pulled from the submodule name
      # ie. rad-dot.service-accounts.docker-deploy will set an
      # account-name of docker-deploy
      account-name = lib.mkOption {
        type = lib.types.str;
        default = config.module._args.name;
        description = "account name to be used for the service account";
      };

      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "extra groups for the users";
      };

      public-ssh-keys = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "Public ssh-key used for deployments";
      };

      # private-ssh-key-paths = lib.mkOption {
      #   type = lib.types.nullOr (lib.types.listOf lib.types.path);
      #   default = null;
      #   description = "Private ssh-key used for deployments";
      # };

      home-directory = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "An optional home directory, useful for persistent data";
      };

      enable-docker = lib.mkEnableOption "docker for service account";

      enable-podman = lib.mkEnableOption "podman for service account";

      zerotier-networks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "A list of zerotier networks to join";
      };
    };
  };
in
{
  /*
    sketching this out:
    service account needs a
    name (obviously)
    groups (for things like docker daemon access)
    home (optional, for accounts which could use it)
    public key (to push deployments to other systems)
    private key (to pull things like docker down from github)
    zerotier networks (optional, useful for creating zerotier networks which are tied to the service)
    docker/podman functionality
  */

  options.rad-dot.service-accounts = lib.mkOption { type = lib.types.attrsOf service-account-type; };

  config =
    let
      # get all zerotier networks that are required
      zerotier-networks = lib.flatten (
        lib.mapAttrsToList (_: { zerotier-networks, ... }: zerotier-networks) cfg
      );

      # any(), but checks if any value in the list is true
      # type:
      # anyBool:: [bool] -> bool
      anyBool = lib.any (n: n);

      # pulls a value out of an attrset and converts it to a list
      # type:
      # mapGetAttr :: String -> Attrset -> [Any]
      mapGetAttr = (attr: set: lib.mapAttrsToList (_: attrset: lib.getAttr attr attrset) set);

      enable-docker = anyBool (mapGetAttr "enable-docker" cfg);
      enable-podman = anyBool (mapGetAttr "enable-podman" cfg);
    in

    {
      # creates each user
      users.users = lib.mapAttrs (
        account-name:
        {
          public-ssh-keys,
          groups,
          home-directory,
          ...
        }:
        {
          isSystemUser = true;
          group = "service-accounts";
          openssh.authorizedKeys.keys = lib.mkIf (public-ssh-keys != null) public-ssh-keys;
          extraGroups = groups ++ lib.optionals enable-docker [ "docker" ];
          home = lib.mkIf (home-directory != null) home-directory;
        }
      ) cfg;

      # declare the service-accounts group exists
      users.groups.service-accounts = { };

      # adds all zerotier networks for service accounts
      services.zerotierone = lib.mkIf (zerotier-networks != [ ]) {
        enable = true;
        joinNetworks = zerotier-networks;
      };

      # enables docker if any requires it
      virtualisation.docker = lib.mkIf enable-docker { enable = true; };

      # enables podman if any requires it
      virtualisation.podman = lib.mkIf enable-podman { enable = true; };
    };
}
