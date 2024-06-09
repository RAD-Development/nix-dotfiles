{
  lib,
  inputs,
  server,
  system,
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
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    extraSpecialArgs = {
      inherit inputs;
      machineConfig = {
        inherit server system;
      };
    };
  };
}
