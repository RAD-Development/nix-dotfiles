{ pkgs, ... }:
{
  programs = {
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      aliases = {
        p = "pull";
        r = "reset --hard";
        f = "push --force-with-lease";
        ci = "commit";
        co = "checkout";
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'";
        st = "status";
        addi = "add --intent-to-add";
        undo = "reset --soft HEAD^";
        kill = "remote prune origin";
      };    

      extraConfig = {
        interactive.singlekey = true;
        pull.rebase = true;
        rebase.autoStash = true;
        safe.directory = "/etc/nixos";
        rerere.enable = true;
        push.autoSetupRemote = true;
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
        alpha-nvim
        barbar-nvim
        cmp-tmux
        copilot-cmp
        csv-vim
        flash-nvim
        fugitive
        fzf-vim
        inc-rename-nvim
        indent-blackline-nvim
        lsp-colors-nvim
        lspkind-nvim
        lualine-nvim
        markdown-preview-nvim
        multicursors-nvim
        nerdtree
        nightfox-nvim
        nvim-cmp
        nvim-comment
        nvim-cursorline
        nvim-dap
        nvim-lspconfig
        nvim-nonicons
        nvim-notify
        nvim-treesitter
        nvim-treesitter-context
        nvim-treesitter-refactor
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars
        nvim-ufo
        nvim-web-devicons
        plenary-nvim
        ranger-vim
        smartpairs-nvim
        todo-comments-nvim
        trouble-nvim
        vim-prettier
        vim-tmux
        vim-tmux-navigator
        zoxide-vim
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
        theme = "agnoster";
        plugins = [
          "git"
          "sudo"
          "docker"
          "kubectl"
          "history"
          "colorize"
          "direnv"
        ];
      };

      shellAliases = {
        cd = "z";
        find = "fd";
        flake = "nvim flake.nix";
        garbage = "sudo nix-collect-garbage -d";
        gpw = "git pull | grep \"Already up-to-date\" > /dev/null; while [ $? -gt 1 ]; do sleep 5; git pull | grep \"Already up-to-date\" > /dev/null; done; notify-send Pull f$";
        grep = "rg";
        l = "ls -lah";
        nixdir = "echo \"use flake\" > .envrc && direnv allow";
        nixeditc = "nvim ~/dotfiles/users/dennis/systems/configuration.nix";
        nixedith = "nvim ~/dotfiles/users/dennis/home.nix";
        qr = "qrencode -m 2 -t utf8 <<< \"$1\"";
        v = "nvim";
        vi = "nvim";
        vim = "nvim";
      };
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

  home.stateVersion = "23.11";
}
