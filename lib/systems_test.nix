let
  systems = import ./systems.nix { lib = import <nixpkgs/lib>; };
  testSystems = {
    system1 = {
      config = {
        formats = {
          iso = "system1-iso";
        };
      };
    };
    system2 = {
      config = {
        formats = {
          iso = "system2-iso";
        };
      };
    };
  };
in
[
  {
    name = "Test getImages";
    actual = systems.getImages testSystems "iso";
    expected = {
      system1 = "system1-iso";
      system2 = "system2-iso";
    };
  }
]
