from subprocess import run


def main():
    extensions = (
        # vscode
        "ms-vscode-remote.remote-ssh",
        "ms-vscode-remote.remote-containers",
        "ms-azuretools.vscode-docker",
        "ms-vsliveshare.vsliveshare",
        "ms-vscode.hexeditor",
        "oderwat.indent-rainbow",
        "usernamehw.errorlens",
        "streetsidesoftware.code-spell-checker",
        "github.copilot",
        # git
        "eamodio.gitlens",
        "codezombiech.gitignore",
        # python
        "charliermarsh.ruff",
        "ms-python.python",
        "ms-python.vscode-pylance",
        # rust
        "rust-lang.rust-analyzer",
        # MD
        "yzhang.markdown-all-in-one",
        # configs
        "tamasfe.even-better-toml",
        "redhat.vscode-yaml",
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
