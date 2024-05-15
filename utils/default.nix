{
  config,
  lib,
  pkgs,
  ...
}:

{
  # create rad-dev namespace for lib
  rad-dev = {
    # any(), but checks if any value in the list is true
    # type:
    # anyBool:: [bool] -> bool
    anyBool = lib.any (n: n);

    # pulls a value out of an attrset and converts it to a list
    # type:
    # mapGetAttr :: String -> Attrset -> [Any]
    mapGetAttr = (attr: set: lib.mapAttrsToList (_: attrset: lib.getAttr attr attrset) set);
  };
}
