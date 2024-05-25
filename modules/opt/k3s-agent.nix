{ ... }:
{
  imports = [ ./k3s-common.nix ];
  services.k3s.role = "agent";
}
