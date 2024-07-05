let
  zfs_main = "/ZFS/Main";
in
{
  inherit zfs_main;
  # main
  main_docker = "${zfs_main}/docker";
  main_docker_configs = "${zfs_main}/docker/configs";
  main_docker_templates = "${zfs_main}/docker/templates";
  main_mirror = "${zfs_main}/mirror";
}
