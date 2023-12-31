{ config, lib, ... }:
let
  httpListen =
    let
      listen = [
        {
          addr = "[::]";
          port = 80;
        }
        {
          addr = "[::]";
          port = 8080;
          extraParameters = [ "proxy_protocol" ];
        }
      ];
    in
    map (x: (x // { addr = "0.0.0.0"; })) listen ++ listen;

  httpsListen =
    let
      listen = [
        {
          addr = "[::]";
          port = 443;
          ssl = true;
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

  defaultListen = httpListen ++ httpsListen;
in
{
  services.nginx = {
    enable = true;
    allRecommendOptions = true;
    generateDhparams = true;
    rotateLogsFaster = true;
    setHSTSHeader = true;
    tcpFastOpen = true;

    virtualHosts = {
      "default" = {
        default = true;
        addSSL = true;
        useACMEHost = "git.wavelens.io";
        listen = defaultListen;
        locations = {
          "/".extraConfig = "return 404;";
        };
      };

      rspamd = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = "/basic/auth/hashes/file";
        serverName = "rspamd.wavelens.io";
        locations = {
          "/" = {
            proxyPass = "http://unix:/run/rspamd/worker-controller.sock:/";
          };
        };
      };

      "auth.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:${toString config.services.portunus.port}";
        };
      };

      "vault.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        };
      };

      "git.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}";
        };
      };

      "cloud.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
      };

      "mail.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
      };

      "rspamd.wavelens.io" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
      };

      "wiki.wavelens.io" = {
        forceSSL = lib.mkForce true;
        enableACME = lib.mkForce true;
        listen = defaultListen;
      };

      "hostoguest.ai" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        serverAliases = [ "www.hostoguest.ai" ];
      };

      "app.hostoguest.ai" = {
        forceSSL = true;
        enableACME = true;
        listen = defaultListen;
        locations = {
          "/".proxyPass = "http://127.0.0.1:8000";
        };
      };
    };
  };
}
