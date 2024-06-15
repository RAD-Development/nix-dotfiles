{
  lib,
  inputs,
  machineConfig,
  ...
}:
{
  boot.default = lib.mkDefault true;

  security.auditd.enable = lib.mkDefault true;

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  programs = {
    zsh.enable = true;
    fish.enable = true;
  };

  users = {
    mutableUsers = lib.mkDefault false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules =
      lib.optionals machineConfig.sops [ inputs.sops-nix.homeManagerModules.sops ]
      ++ lib.optionals machineConfig.nur [ inputs.nur.hmModules.nur ];
    extraSpecialArgs = {
      inherit inputs;
      machineConfig = {
        inherit (machineConfig) server system;
      };
    };
  };
}
