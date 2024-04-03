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
