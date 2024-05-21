{ pulls, branches, ... }:
let
  # create the json spec for the jobset
  makeSpec =
    contents:
    builtins.derivation {
      name = "spec.json";
      system = "x86_64-linux";
      preferLocalBuild = true;
      allowSubstitutes = false;
      builder = "/bin/sh";
      args = [
        (builtins.toFile "builder.sh" ''
          echo "$contents" > $out
        '')
      ];
      contents = builtins.toJSON contents;
    };

  prs = readJSONFile pulls;
  refs = readJSONFile branches;
  repo = "RAD-Development/nix-dotfiles";

  # template for creating a job
  makeJob =
    {
      schedulingshares ? 10,
      keepnr ? 3,
      description,
      flake,
    }:
    {
      inherit
        description
        flake
        schedulingshares
        keepnr
        ;
      enabled = 1;
      type = 1;
      hidden = false;
      checkinterval = 300; # every 6 months
      enableemail = false;
      emailoverride = "";
    };

  # Create a hydra job for a branch
  jobOfRef =
    name:
    { ref, ... }:
    if ((builtins.match "^refs/heads/(.*)$" ref) == null) then
      null
    else
      {
        name = builtins.replaceStrings [ "/" ] [ "-" ] "branch-${name}";
        value = makeJob {
          description = "Branch ${name}";
          flake = "git+ssh://git@github.com/${repo}?ref=${ref}";
        };
      };

  # Create a hydra job for a PR
  jobOfPR = id: info: {
    name = "pr-${id}";
    value = makeJob {
      description = "PR ${id}: ${info.title}";
      flake = "git+ssh://git@github.com/${info.head.repo.full_name}?ref=${info.head.ref}";
    };
  };

  # some utility functions
  # converts json to name/value dicts
  attrsToList = l: builtins.attrValues (builtins.mapAttrs (name: value: { inherit name value; }) l);
  # wrapper function for reading json from file
  readJSONFile = f: builtins.fromJSON (builtins.readFile f);
  # remove null values from a set, in-case of branches that don't exist
  mapFilter = f: l: builtins.filter (x: (x != null)) (map f l);

  # Create job set from PRs and branches
  jobs = makeSpec (
    builtins.listToAttrs (map ({ name, value }: jobOfPR name value) (attrsToList prs))
    // builtins.listToAttrs (mapFilter ({ name, value }: jobOfRef name value) (attrsToList refs))
  );
in
{
  jobsets = jobs;
}
