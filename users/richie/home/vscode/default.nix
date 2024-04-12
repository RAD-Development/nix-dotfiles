{ config, pkgs, ... }:
let
  vscode_dir = "/home/richie/nix-dotfiles/users/richie/home/vscode";
in
{
  # mutable symlinks to keybinds and settings
  xdg.configFile."Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${vscode_dir}/settings.json";
  xdg.configFile."Code/User/keybindings.json".source = config.lib.file.mkOutOfStoreSymlink "${vscode_dir}/keybindings.json";

  home.packages = with pkgs; [ nil ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    mutableExtensionsDir = true;
    extensions = with pkgs.vscode-extensions; [
      # MD
      yzhang.markdown-all-in-one
      # rust
      rust-lang.rust-analyzer
      # python
      ms-python.vscode-pylance
      charliermarsh.ruff
      # congigs
      tamasfe.even-better-toml
      redhat.vscode-yaml
      # git
      eamodio.gitlens
      codezombiech.gitignore
      # vscode
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers
      ms-azuretools.vscode-docker
      ms-vsliveshare.vsliveshare
      ms-vscode.hexeditor
      oderwat.indent-rainbow
      usernamehw.errorlens
      streetsidesoftware.code-spell-checker
      # shell
      timonwong.shellcheck
      foxundermoon.shell-format
      # nix
      jnoortheen.nix-ide
      # other
      esbenp.prettier-vscode
      mechatroner.rainbow-csv
    ];
  };
}
