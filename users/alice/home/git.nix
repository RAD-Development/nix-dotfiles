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
    aliases = {
      gone = ''
        !git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | # dump all branches
                        awk '$2 == "[gone]" {print $1}' | # get nuked branches
                        sed 's/\\x27/\\x5C\\x27/' | # remove single quotes, for xargs reasons
                        xargs -r git branch -D; # nuke the branches
        git for-each-ref --format '%(refname:short) %(upstream)' | # dump all older branches
                        awk 'NF < 2 {print $1}' | # get nuked branches
                        grep -Pv "(^origin/|^origin$|stash)" | # filter out remotes & stash
                        sed 's/\\x27/\\x5C\\x27/' | # remove single quotes, for xargs reasons
                        xargs -r git branch -D # nuke the branches
      '';
    };
    extraConfig = {
      push.autosetupremote = true;
      pull.rebase = true;
      color.ui = true;
    };
  };
}
