{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bfg-repo-cleaner
    candy-icons
    calibre
    # calibre dedrm?
    discord-canary
    etcher
    fanficfare
    ferium
    # gestures replacement
    gpu-viewer
    headsetcontrol
    ipmiview
    ipscan
    masterpdfeditor4
    mons
    # nbt explorer?
    noisetorch
    ocrmypdf
    pinentry-rofi
    playonlinux
    protonmail-bridge
    protontricks
    redshift
    ripgrep
    rpi-imager
    rofi-wayland
    # signal in tray?
    siji
    simple-mtpfs
    slack
    snyk
    spotify
    spotify-player
    #swaylock/waylock?
    sweet-nova
    unipicker
    ventoy
    visual-studio-code
    watchman
    wired
    xboxdrv
    yubico-authenticator-bin
    zoom
  ];
}
