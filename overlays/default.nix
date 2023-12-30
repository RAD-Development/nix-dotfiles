{ inputs, system, ... }:

{
  overlays = [
   (_self: super: {
     bitwarden-directory-connector-cli = inputs.patch-bitwarden-directory-connector.legacyPackages.${system}.bitwarden-directory-connector-cli;
   })
  ];

  # imports = [
  #   "${inputs.patch-bitwarden-directory-connector}/nixos/modules/services/security/bitwarden-directory-connector-cli.nix"
  # ];
}
