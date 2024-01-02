{ config, pkgs, ... }:
let
  wp_th_hello-elementor = pkgs.stdenv.mkDerivation rec {
    name = "hello-elementor";
    version = "3.0.0";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/theme/hello-elementor.${version}.zip";
      hash = "sha256-qzIrgb5/F8zO9G79NvX69ciRW13d47y4oO4W3CpdV/I=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  wp_pl_elementor = pkgs.stdenv.mkDerivation rec {
    name = "elementor";
    version = "3.18.3";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/plugin/elementor.${version}.zip";
      hash = "sha256-gcGwdiTMTkfFSSYzBM6xIvx29YVASZOMndMn4Qq4wzA=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  wp_pl_header-footer-elementor = pkgs.stdenv.mkDerivation rec {
    name = "header-footer-elementor";
    version = "1.6.22";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/plugin/header-footer-elementor.${version}.zip";
      hash = "sha256-gZVSRxaIwwE62pbo8LB+Ut3HQ6fOd/DEJHKaqBKPfJI=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  wp_pl_pro-elements = pkgs.stdenv.mkDerivation rec {
    name = "pro-elements";
    version = "3.18.1";
    src = pkgs.fetchzip {
      url = "https://github.com/proelements/proelements/releases/download/v${version}/pro-elements.zip";
      hash = "sha256-CDg9SjrZK9oFVlUX/LTD7pfx8F8BapXVnLfHSfI/hNk=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  wp_pl_wp-optimize = pkgs.stdenv.mkDerivation rec {
    name = "wp-optimize";
    version = "3.2.22";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/plugin/wp-optimize.${version}.zip";
      hash = "sha256-XGSex1fKGJsThO+Fez4W6Hfw4vc2ZkNgDKSCcKUtAhg=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  wp_pl_wpforms-lite = pkgs.stdenv.mkDerivation rec {
    name = "wpforms-lite";
    version = "1.8.5.4";
    src = pkgs.fetchzip {
      url = "https://downloads.wordpress.org/plugin/wpforms-lite.${version}.zip";
      hash = "sha256-ErGz8zADfGDUe3LHR29WRdmrbVXc/phKFg8ZEBSmtLQ=";
    };
    installPhase = "mkdir -p $out; cp -R * $out/";
  };
in
{
  services.wordpress = {
    webserver = "nginx";
    sites = {
      "hostoguest.ai" = {
        database = {
          createLocally = false;
          name = "web_wp_hostoguest";
          user = "web_wp_hostoguest";
          passwordFile = config.sops.secrets."wordpress/hostoguest-password".path;
        };

        themes = {
          inherit wp_th_hello-elementor;
        };

        plugins = {
          inherit wp_pl_elementor wp_pl_header-footer-elementor wp_pl_pro-elements wp_pl_wp-optimize wp_pl_wpforms-lite;
        };
      };
    };
  };
}
