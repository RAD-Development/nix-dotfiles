{
  pkgs,
  config,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    candy-icons
    discord-canary
    sweet-nova
    vscode
    yubioath-flutter
    beeper
    git
  ];
}

git config --global user.email "Richie@tmmworkshop.com"
git config --global user.name "Richie Cahill"