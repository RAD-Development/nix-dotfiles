{ pkgs, ... }:

{
  programs = {
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      aliases = {
        p = "pull";
        r = "reset --hard";
        ci = "commit";
        co = "checkout";
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
        st = "status";
        undo = "reset --soft HEAD^";
        kill = "remote prune origin";
      };
    };

    neovim = {
      vimAlias = true;
      viAlias = true;
      withPython3 = true;
      extraConfig = ''
        set undofile         " save undo file after quit
        set undolevels=1000  " number of steps to save
        set undoreload=10000 " number of lines to save

        " Save Cursor Position
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
      '';

      plugins = with pkgs.vimPlugins; [
        colorizer
        copilot-vim
        csv-vim
        fugitive
        fzf-vim
        nerdtree
        nvchad
        nvchad-ui
        nvim-treesitter-refactor
        nvim-treesitter.withAllGrammars
        unicode-vim
        vim-cpp-enhanced-highlight
        vim-tmux
        vim-tmux-navigator
      ];
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      shortcut = "Space";
      terminal = ''
        screen-256color"
        set -g mouse on
        # "'';

      plugins = with pkgs.tmuxPlugins; [
        nord
        vim-tmux-navigator
        sensible
        yank
      ];
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "sudo" "docker" "kubectl" "history" "colorize" "direnv" ];
        theme = "agnoster";
      };

      shellAliases = {
        flake = "nvim flake.nix";
        garbage = "sudo nix-collect-garbage -d";
        gpw = ''git pull | grep "Already up-to-date" > /dev/null; while [ $? -gt 1 ]; do sleep 5; git pull | grep "Already up-to-date" > /dev/null; done; notify-send Pull f$'';
        l = "ls -lah";
        nixdir = ''echo "use flake" > .envrc && direnv allow'';
        nixeditc = "nvim ~/dotfiles/system/configuration.nix";
        nixeditpc = "nvim ~/dotfiles/system/program.nix";
        pypi = "pip install --user";
        qr = ''qrencode -m 2 -t utf8 <<< "$1"'';
        update = "sudo nixos-rebuild switch --fast --flake /root/dotfiles/ -L";
        v = "nvim";
        jc = "journalctl -xe";
        sc = "sudo systemctl";
      };
    };
  };

  home.stateVersion = "23.11";
}
