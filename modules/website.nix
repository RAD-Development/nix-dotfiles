{ config, pkgs, lib, ... }:
let
  eachSite = config.services.staticpage.sites;

  siteOpts = { lib, name, config, ... }:
    {
      options = {
        package = lib.mkPackageOption pkgs "page" { };

        root = lib.mkOption {
          type = lib.types.str;
          description = "The Document-Root folder in /var/lib";
        };

        domain = lib.mkOption {
          type = lib.types.str;
          example = "example.com";
          description = "The staticpage's domain.";
        };

        subdomain = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          example = "app";
          description = "The staticpage subdomain.";
        };

        usePHP = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Configure the Nginx Server to use PHP";
        };

        configureNginx = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Configure the Nginx Server to serve the site with acne";
        };
      };
    };
in
{
  options.services.staticpage = {
    enable = lib.mkEnableOption "staticpage";

    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule siteOpts);
      default = { };
      description = lib.mdDoc "Specification of one or more Staticpages sites to serve";
    };
  };

  config = lib.mkIf (eachSite != { }) (lib.mkMerge [{
    services.nginx = {
      virtualHosts = lib.mkMerge [
        (lib.mapAttrs'
          (name: cfg: {
            name = "${(if (cfg.subdomain == null) then "${cfg.domain}" else "${cfg.subdomain}.${cfg.domain}")}";
            value = {
              root = "/var/lib/www/${cfg.root}";

              forceSSL = true;
              enableACME = true;
              serverAliases = lib.mkIf (cfg.subdomain == null) [ "www.${cfg.domain}" ];

              locations."= /favicon.ico" = {
                extraConfig = ''
                  log_not_found off;
                  access_log off;
                '';
              };
              locations."= /robots.txt" = {
                extraConfig = ''
                  allow all;
                  log_not_found off;
                  access_log off;
                '';
              };
              locations."~* ^/.well-known/" = {
                extraConfig = ''
                  allow all;
                '';
              };
              locations."~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$" = {
                extraConfig = ''
                  try_files $uri @rewrite;
                  expires max;
                  log_not_found off;
                '';
              };
              locations."~ ^/sites/.*/files/styles/" = {
                extraConfig = ''
                  try_files $uri @rewrite;
                '';
              };
            } // lib.optionalAttrs cfg.usePHP {
              locations."~ '\.php$|^/update.php'" = {
                extraConfig = ''
                  include ${pkgs.nginx}/conf/fastcgi_params;
                  include ${pkgs.nginx}/conf/fastcgi.conf;
                  fastcgi_pass  unix:${config.services.phpfpm.pools.${name}.socket};
                  fastcgi_index index.php;
  
                  fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
                  # Ensure the php file exists. Mitigates CVE-2019-11043
                  try_files $fastcgi_script_name =404;
  
                  # Block httpoxy attacks. See https://httpoxy.org/.
                  fastcgi_param HTTP_PROXY "";
                  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                  fastcgi_param PATH_INFO $fastcgi_path_info;
                  fastcgi_param QUERY_STRING $query_string;
                  fastcgi_intercept_errors on;
                '';
              };

              locations."~ \..*/.*\.php$" = {
                extraConfig = ''
                  return 403;
                '';
              };
              locations."~ ^/sites/.*/private/" = {
                extraConfig = ''
                  return 403;
                '';
              };
              locations."~ ^/sites/[^/]+/files/.*\.php$" = {
                extraConfig = ''
                  deny all;
                '';
              };
              locations."/" = {
                extraConfig = ''
                  try_files $uri /index.php?$query_string;
                '';
              };
              locations."@rewrite" = {
                extraConfig = ''
                  rewrite ^ /index.php;
                '';
              };
              locations."~ /vendor/.*\.php$" = {
                extraConfig = ''
                  deny all;
                  return 404;
                '';
              };
              locations."~ ^/sites/.*/files/styles/" = {
                extraConfig = ''
                  try_files $uri @rewrite;
                '';
              };
              locations."~ ^(/[a-z\-]+)?/system/files/" = {
                extraConfig = ''
                  try_files $uri /index.php?$query_string;
                '';
              };
            } // lib.optionalAttrs (!cfg.usePHP) {
              locations."/" = {
                extraConfig = ''
                  index index.html;
                  try_files $uri $uri/ $uri.html =404;
                '';
              };
            };
          })
          (lib.filterAttrs (n: v: v.configureNginx) eachSite))
      ];
    };

    services.phpfpm.pools = lib.mkMerge [
      (lib.mapAttrs
        (name: cfg: {
          user = "nginx";
          settings = {
            "listen.owner" = config.services.nginx.user;
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.max_requests" = 500;
            "pm.start_servers" = 2;
            "pm.min_spare_servers" = 2;
            "pm.max_spare_servers" = 5;
            "php_admin_value[error_log]" = "stderr";
            "php_admin_flag[log_errors]" = true;
            "catch_workers_output" = true;
          };
          phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
        })
        (lib.filterAttrs (n: v: v.usePHP) eachSite))
    ];
  }]);
}
