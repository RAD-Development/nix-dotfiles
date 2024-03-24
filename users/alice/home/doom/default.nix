{
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg.configFile."doom/config.el".source = ./config.el;
  xdg.configFile."doom/custom.el".source = ./custom.el;
  xdg.configFile."doom/init.el".source = ./init.el;
  xdg.configFile."doom/packages.el".source = ./packages.el;
  xdg.configFile."doom/snippets/cc-mode/cc-doxy".source = ./snippets/cc-mode/cc-doxy;
  xdg.configFile."doom/snippets/cc-mode/README.md".source = ./snippets/cc-mode/README.md;
}
