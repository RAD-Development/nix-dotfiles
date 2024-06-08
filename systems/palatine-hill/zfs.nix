{
  config,
  lib,
  pkgs,
  ...
}:
let
  bootkey = key: { "/crypto/keys/${key}" = /crypto/keys/${key}; };
  zfskeys = [
    "zfs-attic-key"
    "zfs-backup-key"
    "zfs-calibre-key"
    "zfs-db-key"
    "zfs-docker-key"
    "zfs-games-key"
    "zfs-hydra-key"
    "zfs-libvirt-key"
    "zfs-main-key"
    "zfs-nxtcld-key"
    "zfs-torr-key"
    "zfs-var-docker-key"
    "zfs-nix-store-key"
  ];
in
{
  boot = {
    zfs.extraPools = [ "ZFS-primary" ];
    filesystem = "zfs";
    initrd.secrets = lib.mergeAttrsList (map bootkey zfskeys);
    extraModprobeConfig = ''
      options zfs zfs_arc_min=82463372083
      options zfs zfs_arc_max=192414534860
    '';
  };

  services = {
    zfs = {
      trim.enable = true;
      autoScrub.enable = true;
    };

    sanoid = {
      enable = true;

      datasets = {
        "ZFS-primary/attic".useTemplate = [ "nix-prod" ];
        "ZFS-primary/backups".useTemplate = [ "production" ];
        "ZFS-primary/calibre".useTemplate = [ "production" ];
        "ZFS-primary/db".useTemplate = [ "production" ];
        "ZFS-primary/docker".useTemplate = [ "production" ];
        "ZFS-primary/hydra".useTemplate = [ "nix-prod" ];
        "ZFS-primary/nextcloud".useTemplate = [ "production" ];
        # all docker containers should have a bind mount if they expect lasting zfs snapshots
        "ZFS-primary/vardocker".useTemplate = [ "nix-prod" ];
        "ZFS-primary/games" = {
          useTemplate = [ "games" ];
          recursive = true;
          processChildrenOnly = true;
        };
      };

      templates = {
        # full resiliency
        production = {
          frequently = 0;
          hourly = 36;
          daily = 30;
          monthly = 6;
          yearly = 3;
          autosnap = true;
          autoprune = true;
        };
        # some resiliency, but not much
        # common option for things like nix store and attic where there is
        # already a lot of resiliency built in
        nix-prod = {
          frequently = 4;
          hourly = 24;
          daily = 7;
        };
        # much shorter lived than others
        games = {
          frequently = 6;
          hourly = 36;
          daily = 3;
          autosnap = true;
          autoprune = true;
        };
      };
    };
  };
}
