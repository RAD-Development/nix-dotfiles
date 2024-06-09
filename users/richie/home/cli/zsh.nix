{
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "colored-man-pages"
        "rust"
        "systemd"
        "tmux"
        "ufw"
        "z"
      ];
    };
    shellAliases = {
      "sgc" = "sudo git -C /root/dotfiles";

      ## Utilities
      "lrt" = "eza --icons -lsnew";
      "ls" = "eza";
      "ll" = "eza --long --group";
      "la" = "eza --all";

      "rspace" = "'for f in *\ *; do mv \"$f\" \"\${f// /_}\"; done'";
      "rebuild" = "sudo nixos-rebuild switch --flake /home/richie/projects/nix-dotfiles#$HOST";
    };
  };
}
