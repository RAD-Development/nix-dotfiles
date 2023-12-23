let
  alice = "ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  dennis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFc7O+5G6fwpXv9j/miJzST6g1AKkPTFtKwuj6j8NC+";

  allUsers = [alice dennis];

  palatine-hill = "ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
  photon = "ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

  allSystems = [palatine-hill photon];
in {
  "TEST.age".publicKeys = allUsers ++ [photon];
}