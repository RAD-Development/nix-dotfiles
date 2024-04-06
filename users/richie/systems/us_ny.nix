{
  config,
  lib,
  pkgs,
  ...
}:
{
  time.timeZone = "America/New_York";
  console.keyMap = "us";

  i18n = {
    defaultLocale = "en_US.utf8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };
}
