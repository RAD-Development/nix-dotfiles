{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
  };
  home.packages = with pkgs; [
    cmake
    shellcheck
    glslang
    pipenv
    python312Packages.isort
    python312Packages.pynose
    python312Packages.pytest

    # rust tools
    trunk
    wasm-pack
    cargo-tarpaulin
    cargo-watch
    cargo-generate
    diesel-cli

    # nix tools
    nil
    nixfmt-rfc-style

    # markdown
    nodePackages.markdownlint-cli

    # doom emacs dependencies
    yaml-language-server
    nodePackages.typescript-language-server
    nodePackages.bash-language-server
    pyright
    cmake-language-server
    multimarkdown
    rustc
    cargo
    rust-analyzer
    clang
    clang-tools
    wakatime

    # dependencies for nix-dotfiles/hydra-check-action
    nodejs_20
    nodePackages.prettier
    treefmt
  ];
}
