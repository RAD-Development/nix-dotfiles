{
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg.configFile."doom/config.el".source = "./doom/config.el";
  xdg.configFile."doom/custom.el".source = "./doom/custom.el";
  xdg.configFile."doom/init.el".source = "./doom/init.el";
  xdg.configFile."doom/packages.el".source = "./doom/packages.el";
  xdg.configFile."doom/snippets/cc-mode/cc-doxy".source = "./doom/snippets/cc-mode/cc-doxy";
  xdg.configFile."doom/snippets/cc-mode/README.md".source = "./doom/snippets/cc-mode/README.md";
}
