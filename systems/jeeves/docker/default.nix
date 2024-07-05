{ lib, ... }:
{
  imports =
    let
      files = builtins.attrNames (builtins.readDir ./.);
      nixFiles = builtins.filter (name: lib.hasSuffix ".nix" name && name != "default.nix") files;
    in
    map (file: ./. + "/${file}") nixFiles;

  virtualisation.oci-containers.backend = "docker";
}
