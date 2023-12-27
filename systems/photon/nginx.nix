{ config, ... }:
let
  defaultListen = let
    listen = [
      {
        addr = "[::]";
        port = 80;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::]";
        port = 8080;
        extraParameters = [ "proxy_protocol" ];
      }
      {
        addr = "[::]";
        port = 8443;
        ssl = true;
        extraParameters = [ "proxy_protocol" ];
      }
    ];
  in
  map (x: (x // { addr = "0.0.0.0"; })) listen ++ listen;
in {
  services.nginx = {
    enable = true;
    allRecommendOptions = true;
    generateDhparams = true;
    openFirewall = true;
    recommendedDefaults = true;
    resolverAddrFromNameserver = true;
    rotateLogsFaster = true;
    setHSTSHeader = true;
    tcpFastOpen = true;

    quic = {
      enable = true;
      bpf = true;
    };

    # TODO
    # default404Server = {
    #   enable = true;
    #   acmeHost = "";
    # };

    virtualHosts = {
      "auth.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:${toString config.services.portunus.port}";
        };
      };

      "bitwarden.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
      };

      "git.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:3000";
        };
      };
      
      "cloud.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:3000";
        };
      };
    };
  };
}