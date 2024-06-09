{ config, pkgs, ... }:
let
  vscode_dir = "/home/richie/projects/nix-dotfiles/users/richie/home/gui/vscode";
in
{
  # mutable symlinks to key binds and settings
  xdg.configFile."Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${vscode_dir}/settings.json";
  xdg.configFile."Code/User/keybindings.json".source = config.lib.file.mkOutOfStoreSymlink "${vscode_dir}/keybindings.json";

  home.packages = with pkgs; [ nil ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
  };
}
