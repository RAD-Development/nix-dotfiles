{ lib, ... }:
{
  nix = {
    diffSystem = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-outputs = true;
      builders-use-substitutes = true;
      connect-timeout = 20;
    };

    # free up to 10 gb when only 1 gb left
    extraOptions = ''
      min-free = ${toString (1 * 1024 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = [ "01:00" ];
    };
  };
}
