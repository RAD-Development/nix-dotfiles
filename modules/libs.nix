{ lib, pkgs, ... }:
{
  programs.nix-ld = {
    enable = lib.mkDefault true;
    libraries = with pkgs; [
      acl
      attr
      bzip2
      curl
      glib
      libglvnd
      libmysqlclient
      libsodium
      libssh
      libxml2
      openssl
      stdenv.cc.cc
      systemd
      util-linux
      xz
      zlib
      zlib-ng
      zstd
    ];
  };
}
