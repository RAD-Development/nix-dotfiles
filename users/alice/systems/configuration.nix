{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./non-server.nix ];

  services.fwupd.enable = true;

  nix.settings = {
    substituters = [
      "https://cache.nixos.org/?priority=1&want-mass-query=true"
      "https://attic.alicehuston.xyz/cache-nix-dot?priority=4&want-mass-query=true"
      "https://cache.alicehuston.xyz/?priority=5&want-mass-query=true"
      "https://nix-community.cachix.org/?priority=10&want-mass-query=true"
    ];
    trusted-substituters = [
      "https://cache.nixos.org"
      "https://attic.alicehuston.xyz/cache-nix-dot"
      "https://cache.alicehuston.xyz"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.alicehuston.xyz:SJAm8HJVTWUjwcTTLAoi/5E1gUOJ0GWum2suPPv7CUo=%"
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache-nix-dot:0hp/F6mUJXNyZeLBPNBjmyEh8gWsNVH+zkuwlWMmwXg="
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
