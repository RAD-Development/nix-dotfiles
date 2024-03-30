{
  pkgs,
  config,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    bfg-repo-cleaner
    bitwarden-cli
    candy-icons
    calibre
    # calibre dedrm?
    cinnamon.nemo
    discord-canary
    eza
    fanficfare
    ferium
    firefox
    # gestures replacement
    git
    gpu-viewer
    headsetcontrol
    ipmiview
    ipscan
    kitty
    masterpdfeditor4
    mons
    # nbt explorer?
    neovim
    noisetorch
    ocrmypdf
    playonlinux
    protonmail-bridge
    protontricks
    redshift
    restic
    ripgrep
    rpi-imager
    rofi-wayland
    # signal in tray?
    siji
    simple-mtpfs
    slack
    snyk
    sops
    spotify
    spotify-player
    #swaylock/waylock?
    sweet-nova
    unipicker
    ventoy
    vscode
    watchman
    xboxdrv
    yubioath-flutter
    zoom
  ];
  # ++ [ inputs.wired.packages.${system}.wired ];
}
