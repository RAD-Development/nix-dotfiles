{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    enable = true;
    signing = {
      key = "F63832C3080D6E1AC77EECF80B4245FFE305BC82";
      signByDefault = true;
    };
    userEmail = "aliceghuston@gmail.com";
    userName = "ahuston-0";
    includes.config.contents = {
      alias = {
        gone =
          !"git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D";
      };
      push.autosetupremote = true;
      pull.rebase = true;
      color.ui = true;
    };
  };
}
