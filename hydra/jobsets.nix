{
  nixpkgs,
  pulls,
  branches,

  ...
}:
let
  pkgs = import nixpkgs { };

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
  repo = "ahuston-0/nix-dotfiles-hydra";

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
  jobOfRef =
    name:
    { ref, ... }:
    if isNull (builtins.match "^refs/heads/(.*)$" ref) then
      null
    else
      {
        name = (builtins.replaceStrings [ "/" ] [ "-" ] "branch-${name}");
        value = makeJob {
          description = "Branch ${name}";
          flake = "git+ssh://git@github.com/${repo}?ref=${ref}";
        };
      };
  jobOfPR = id: info: {
    name = "pr-${id}";
    value = makeJob {
      description = "PR ${id}: ${info.title}";
      flake = "git+ssh://git@github.com/${info.head.repo.full_name}?ref=${info.head.ref}";
    };
  };
  attrsToList = l: builtins.attrValues (builtins.mapAttrs (name: value: { inherit name value; }) l);
  readJSONFile = f: builtins.fromJSON (builtins.readFile f);
  mapFilter = f: l: builtins.filter (x: !(isNull x)) (map f l);
  jobs = makeSpec (
    builtins.listToAttrs (map ({ name, value }: jobOfPR name value) (attrsToList prs))
    // builtins.listToAttrs (mapFilter ({ name, value }: jobOfRef name value) (attrsToList refs))
    // {
      main = makeJob {
        description = "main";
        flake = "github:${repo}";
        keepnr = 10;
        schedulingshares = 100;
      };
    }
  );
  log = {
    jobsets = jobs;
  };
in
{
  jobsets = jobs;
  # // pkgs.runCommand "spec-jobsets.json" { } ''
  #   cat >$out <<EOF
  #   ${jobs}
  #   EOF
  #   # This is to get nice .jobsets build logs on Hydra
  #   cat >tmp <<EOF
  #   ${builtins.toJSON log}
  #   EOF
  #   ${pkgs.jq}/bin/jq . tmp
  # '';
}
