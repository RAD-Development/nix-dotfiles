{ pkgs, ... }:
{
  fonts = {
    fontconfig.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "DroidSansMono"
          "Hack"
          "DejaVuSansMono"
          "Noto"
          "OpenDyslexic"
        ];
      })
    ];
  };
}
