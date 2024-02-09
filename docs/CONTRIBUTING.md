# Contributing to nix-dotfiles

## Preliminary info

This repository is written using nix-flakes on nix-unstable all the way
through. We do not currently have a way to provide support for NixOS stable
releases and nor do we plan to (please open an issue if that
is a breaking issue so we can better understand your use-case).

## Style Guide

We do not currently have a set formatter, although work is being done to
narrow down our options. See
[our fork of the rfc-0101 repo](https://github.com/RAD-Development/rfc-0101).

## Active Development

To contribute to the repo, you can either ask to be provided a role
(for those who are adding machines to the repo), or fork the repo and open a PR
(for those who are making external contributions).

Our main branch is protected (not even admins can directly push to main) and
all PRs require at least one approval. PRs which touch global files
(`flake.nix`, `modules/`, `systems/configuration.nix`, `.sops.yaml`, etc)
must have two approvals and may require more subject to the approvers discretion
(ie. a change which affect all servers or users).

### Branching

We use the below guide for creating branches currently. It is not necessarily
a strict standard, but if not followed will lead to questions from reviewers,
and will eventually trip a check when merging to main.

<!--
Need to figure out how to make markdownlint ignore tables. I know its possible
but I cannot be bothered rn
-->

| Branch Name      | Use Case                                                                                                                                                                             |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| main             | protected branch which all machines pull from, do not try to push directly                                                                                                            |
| feature/\<item\> | \<item\> is a new feature being added to the repo, for personal or common use                                                                                                        |
| fixup/\<item\>   | \<item\> is a non-urgent bug, PRs merging from these branches should be merged when possible, but are not considered mission-critical                                                |
| hotfix/\<item\>  | \<item\> is a mission-critical bug, either affecting all users or a breaking change on a user's machines. These PRs should be reviewed ASAP                                          |
| urgent/\<item\>  | Accepted as an alias for the above, due to dev's coming from multiple standards and the criticality of these issues                                                                  |
| exp/\<item\>     | \<item\> is a non-critical experiment. This is used for shipping around potential new features or fixes to multiple branches                                                         |
| merge/\<item\>   | \<item\> is a temporary branch and should never be merged directly to main. This is solely used for addressing merge conflicts which are too complex to be merged directly on branch |

## Secrets

We allow secrets to be embedded in the repository using `sops-nix`. As part of
the process everything is encrypted, however adding a new user is a change
that every existing SOPS user needs to participate in. Please reach out to
@ahuston-0, @DerDennnisOP, or @RichieCahill if you are interested
in using secrets on your machines.

## CI/CD

Our CI is currently a detached Hydra instance, which does not provide
feedback to the repository. Research is being done into a GitHub bot which will
provide live feedback on PR's and such.

Deployments are managed via two services for servers, one is the standard
`nixos-upgrade.service` which is bundled into NixOS. The current configuration
is that the `main` branch will be build every 24 hours on a per-server basis.
The other service is a custom `autopull@dotfiles.service`, which by default
will pull the `main` branch into `/root/dotfiles`. This service can be disabled
if you do not want it, but it is rather useful for experimenting and debugging.
