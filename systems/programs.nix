{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bat
    btop
    croc
    deadnix
    direnv
    fd
    file
    htop
    hwloc
    iperf3
    jp2a
    jq
    lsof
    lynis
    ncdu
    neofetch
    nix-init
    nix-output-monitor
    nix-prefetch
    nix-tree
    nixpkgs-fmt
    nmap
    pciutils
    python3
    qrencode
    ripgrep
    smartmontools
    speedtest-cli
    tig
    tokei
    tree
    unzip
    usbutils
    ventoy
    wget
    zoxide
    zsh-nix-shell
  ];
}
