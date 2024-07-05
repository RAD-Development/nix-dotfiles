from subprocess import run


def get_installed_extensions():
    process = run("code --list-extensions".split(), check=True, capture_output=True)
    return set(process.stdout.decode("utf-8").strip().split("\n"))


def main():
    print("starting vscode extension manager")

    extensions = {
        # vscode
        "ms-azuretools.vscode-docker",
        "ms-vscode-remote.remote-containers",
        "ms-vscode-remote.remote-ssh-edit",
        "ms-vscode-remote.remote-ssh",
        "ms-vscode.hexeditor",
        "ms-vscode.remote-explorer",
        "ms-vsliveshare.vsliveshare",
        "oderwat.indent-rainbow",
        "usernamehw.errorlens",
        # git
        "codezombiech.gitignore",
        "eamodio.gitlens",
        "gitHub.vscode-github-actions",
        # python
        "charliermarsh.ruff",
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.debugpy",
        # rust
        "rust-lang.rust-analyzer",
        # MD
        "davidanson.vscode-markdownlint",
        "yzhang.markdown-all-in-one",
        # configs
        "redhat.vscode-yaml",
        "tamasfe.even-better-toml",
        # shell
        "timonwong.shellcheck",
        "foxundermoon.shell-format",
        # nix
        "jnoortheen.nix-ide",
        # database
        "mtxr.sqltools-driver-pg",
        "mtxr.sqltools",
        # other
        "esbenp.prettier-vscode",
        "mechatroner.rainbow-csv",
        "streetsidesoftware.code-spell-checker",
        "supermaven.supermaven",
    }

    installed_extensions = get_installed_extensions()

    missing_extensions = extensions.difference(installed_extensions)
    for extension in missing_extensions:
        run(f"code --install-extension {extension} --force".split(), check=True)

    if extra_extensions := installed_extensions.difference(extensions):
        print(f"Extra extensions installed: {extra_extensions}")

    print("vscode extension manager finished")


if __name__ == "__main__":
    main()
