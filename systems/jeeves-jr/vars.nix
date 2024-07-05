let
  zfs_main = "/ZFS/Main";
in
{
  inherit zfs_main;
  # main
  main_docker = "${zfs_main}/Docker";
  main_docker_configs = "${zfs_main}/Docker/configs";
  main_docker_templates = "${zfs_main}/Docker/templates";
  main_mirror = "${zfs_main}/Mirror";
}
