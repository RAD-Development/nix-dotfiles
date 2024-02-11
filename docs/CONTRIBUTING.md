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

### Review Process

For PR's that impact personal files (personal SOPS files, SSH keys, your laptops,
your servers), those can be added with one approval and will eventually be
auto-approved. However, for PR's affecting global files you need two
approvals based on the latest commit (stale approvals will not work).

In the event that quorum cannot be reached on approvals (specifically members
that cannot approve who normally would), the PR will be placed on-hold unless
a member who is unable to approve defers their approval power. This deferral
must be publicly acknowledged in the PR and confirmed by another member.
This process essentially acknowledges that at least two people besides the
author are aware of the PR, however the third is deferring their approval powers
to those already involved.

This quorum rule can only be overrided for critical items (branches beginning
in `hotfix/` or `urgent/`), but an additional reviewer must be tagged regardless
and the assignee must assert that the PR has been tested on at least one
machine. Please see [Critical Issues](#critical-issues) for further details.

### Nix Project

All issues must be tagged to the `Nix Flake Features` project, and any PR's
which do not have an associated issue must be tagged to the same. It is
**highly recommended** that all PR's be tagged to an issue but PR's should
not be rejected if they are not tagged to an issue.

Any issue or PR that is tagged to the project must have a priority (High/Medium
/Low) and an estimate (rough amount of time in hours) associated. Start date
and end date must be included for non-critical items (branches not beginning
with `hotfix/` or `urgent/`). This is done in order to understand effort and
criticality of the project item. Please see [Critical Issues](#critical-issues)
for further details.

### Critical Issues

As previously described, a critical issue is one which has a branch associated
with it beginning with `urgent/` or `hotfix/`. Any reviewer who is going to
review one of these PR's must assert that they have read and understood these
rules.

#### Implications

- Critical issues may bypass the [quorum rules](#review-process), as long as the
  PR has been tested on at least one machine
  - Issues which bypass the quorum process must have a second reviewer tagged
  - All critical issues which bypass the approval process must have an RCA issue
    opened and the RCA logged into the `inc/` folder
  - The second reviewer has 2 weeks to retroactively review and approve the PR
  - If the retro does not happen in the given window, an issue shall be opened
    to either re-review the PR or to revert and replace the fix with a 
    permanent solution
- Critical issues must be tagged to `Nix Flake Features` project, and must have
  a priority of `High` and an estimate tagged. Start and end date are not needed

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
