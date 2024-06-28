from subprocess import run


def main():
    extensions = (
        # vscode
        "ms-azuretools.vscode-docker",
        "ms-vscode-remote.remote-containers",
        "ms-vscode-remote.remote-ssh",
        "ms-vscode.hexeditor",
        "ms-vsliveshare.vsliveshare",
        "oderwat.indent-rainbow",
        "streetsidesoftware.code-spell-checker",
        "supermaven.supermaven",
        "usernamehw.errorlens",
        # git
        "codezombiech.gitignore",
        "eamodio.gitlens",
        # python
        "charliermarsh.ruff",
        "ms-python.python",
        "ms-python.vscode-pylance",
        # rust
        "rust-lang.rust-analyzer",
        # MD
        "yzhang.markdown-all-in-one",
        # configs
        "redhat.vscode-yaml",
        "tamasfe.even-better-toml",
        # shell
        "timonwong.shellcheck",
        "foxundermoon.shell-format",
        # nix
        "jnoortheen.nix-ide",
        # other
        "esbenp.prettier-vscode",
        "mechatroner.rainbow-csv",
    )

    for extension in extensions:
        run(f"code --install-extension {extension} --force".split(), check=True)


if __name__ == "__main__":
    main()
