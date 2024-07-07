{ ... }:

{
  xdg.configFile = {
    "doom/config.el".source = ./config.el;
    "doom/custom.el".source = ./custom.el;
    "doom/init.el".source = ./init.el;
    "doom/packages.el".source = ./packages.el;
  };
}
