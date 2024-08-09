{ pkgs, ... }:
let
  randWallpaper = pkgs.runCommand "stylix-wallpaper" { } ''
    numWallpapers =
    $((1 + $RANDOM % 10))

  '';
in
{
  stylix = {
    enable = true;
    image = randWallpaper;
    polarity = "dark";
  };
}
