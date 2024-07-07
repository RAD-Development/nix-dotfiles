{ pkgs, inputs, ... }:
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
    rar
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
    poetry
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
    inputs.server_tools.packages.x86_64-linux.server_tools
  ];
}
