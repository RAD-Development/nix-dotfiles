{ pkgs, ... }:
{
  fonts = {
    fontconfig.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [ nerdfonts ];
  };
}
