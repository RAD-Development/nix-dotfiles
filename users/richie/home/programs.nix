{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # cli
    bat
    btop
    eza
    git
    gnupg
    ncdu
    neofetch
    ripgrep
    sops
    starship
    tmux
    zoxide
    # system info
    hwloc
    lynis
    pciutils
    smartmontools
    usbutils
    # networking
    iperf3
    nmap
    wget
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
