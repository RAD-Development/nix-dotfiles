{ input, ... }: {
  users = [ "alice" "richie" ];
  modules = [ input.attic.nixosModules.atticd ];
}
