{ lib, ... }:
{
  # create rad-dev namespace for lib
  rad-dev = rec {
    systems = import ./systems.nix { inherit lib; };
    container-utils = import ./container-utils.nix { inherit lib; };

    # any(), but checks if any value in the list is true
    #
    # args:
    # n: list of booleans
    #
    # type:
    # anyBool:: [bool] -> bool
    anyBool = lib.any (n: n);

    # pulls a value out of an attrset and converts it to a list
    #
    # args:
    # attr: attribute to search for in an attrset
    # set: attrset to search
    #
    # type:
    # mapGetAttr :: String -> AttrSet -> [Any]
    mapGetAttr = attr: set: lib.mapAttrsToList (_: attrset: lib.getAttr attr attrset) set;

    # gets list of files and directories inside of a directory
    #
    # args:
    # base: base path to search
    # dir: directory to get files from
    #
    # type:
    # ls :: Path -> String -> [String]
    ls = dir: lib.attrNames (builtins.readDir dir);

    # gets list of directories inside of a given directory
    #
    # args:
    # base: base path to search
    # dir: directory to get files from
    #
    # type:
    # lsdir :: Path -> String -> [String]
    lsdir =
      dir:
      lib.optionals (builtins.pathExists dir) (
        lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dir))
      );

    # return full paths of all files in a directory
    #
    # args:
    # base: base path to search
    # dir: path to get files from
    #
    # type:
    # fileList :: Path -> String -> [Path]
    fileList = dir: map (file: dir + "/${file}") (ls dir);

  };
}
