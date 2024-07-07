# Nix Dotfiles

This repository contains the flake required to build critical and personal
infrastructure running NixOS. The setup can be explored as follows.

This repo supports `x86_64-linux` and (theorically) `aarch64-linux`.

## Setting Up

Please see [our setup guide](./docs/setting-up.md) for more information on how
to onboard a new user or system.

## For Those Interested

Although we are not actively looking for new members to join in on this repo,
we are not strictly opposed. Please reach out to
[@ahuston-0](https://github.com/ahuston-0) or
[@RichieCahill](https://github.com/RichieCahill)
for further information.

## Repo Structure

- `docs/`: public documentation, including contributors and setup guides
- `hydra/`: hydra configuration, used for our CI/CD
- `keys/`: PGP public keys, for those who are using `SOPS` for secrets
- `lib`: custom nix library functions, including general utility functions and
  dynamic system construction
- `modules/`: Nix modules created by us for common services or overrides
  (fail2ban, hydra, certain boot params, etc.)
- `systems/`: config for common *server* components, as well as per-server configurations
- `users/<user>/`: includes per-user configs for `home-manager`, `SOPS`, and
  `SSH` keys
- `utils/`: utility scripts primarily used for dependency updates

## Contributing

For members of our organization who are looking to either contribute to the
existing infrastructure, or onboard their own hardware, please see
[our contributors guide](./docs/CONTRIBUTING.md)
