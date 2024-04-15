{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # cli
    bat
    btop
    git
    gnupg
    ncdu
    neofetch
    ripgrep
    sops
    starship
    zoxide
    zsh-nix-shell
    # system info
    hwloc
    lynis
    pciutils
    smartmontools
    usbutils
    # netowking
    iperf3
    nmap
    wget
    # GUI
    beeper
    candy-icons
    discord-canary
    firefox
    obsidian
    sweet-nova
    # python
    python3
    ruff
    # Rust packages
    topgrade
    trunk
    wasm-pack
    cargo-watch
    cargo-generate
    cargo-audit
    cargo-update
    # nix
    nix-init
    nix-output-monitor
    nix-prefetch
    nix-tree
    nixpkgs-fmt
  ];
}
