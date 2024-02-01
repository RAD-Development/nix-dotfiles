{ config, lib, ... }:

let
  cfg = config.services.hydra;
in
{
  config = {
    services.hydra.extraConfig = lib.mkDefault (lib.concatLines [
      cfg.extraConfig
      ''
        <git-input>
          timeout = 3600
        </git-input>
      ''
    ]);
  };
}
