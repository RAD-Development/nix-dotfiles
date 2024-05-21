{
  config,
  lib,
  pkgs,
  ...
}:

{
  xdg.configFile = {
    "doom/config.el".source = ./config.el;
    "doom/custom.el".source = ./custom.el;
    "doom/init.el".source = ./init.el;
    "doom/packages.el".source = ./packages.el;
    "doom/snippets/cc-mode/cc-doxy".source = ./snippets/cc-mode/cc-doxy;
    "doom/snippets/cc-mode/README.md".source = ./snippets/cc-mode/README.md;
  };
}
