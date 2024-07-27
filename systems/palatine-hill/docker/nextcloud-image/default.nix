{ pkgs, ... }:
let
  nextcloud-apache = pkgs.dockerTools.pullImage (import ./nextcloud-apache.nix);
in

pkgs.dockerTools.buildImage {
  name = "nextcloud-custom";
  tag = "latest";
  fromImage = nextcloud-apache;
  diskSize = 8192;
  buildVMMemorySize = 8192;
  compressor = "zstd";
  # contents = ./.;
  # copyToRoot = pkgs.buildEnv {
  #   name="supervisord";
  #   paths = [./.];
  #   pathsToLink = [ "./supervisord.conf" ];

  # };
  useFUSEOverlayFS = true;
  # enableFakechroot = true;
  runAsRoot = ''
    set -ex; \
        \
        /usr/bin/apt-get update; \
        /usr/bin/apt-get install -y --no-install-recommends \
            ffmpeg \
            ghostscript \
            libmagickcore-6.q16-6-extra \
            procps \
            smbclient \
            supervisor \
    #       libreoffice \
        ; \
        rm -rf /var/lib/apt/lists/*

    set -ex; \
        \
        savedAptMark="$(apt-mark showmanual)"; \
        \
        /usr/bin/apt-get update; \
        /usr/bin/apt-get install -y --no-install-recommends \
            libbz2-dev \
            libc-client-dev \
            libkrb5-dev \
            libsmbclient-dev \
        ; \
        \
        /usr/local/bin/docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
        /usr/local/bin/docker-php-ext-install \
            bz2 \
            imap \
        ; \
        /usr/local/bin/pecl install smbclient; \
        /usr/local/bin/docker-php-ext-enable smbclient; \
        \
    # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
        /usr/bin/apt-mark auto '.*' > /dev/null; \
        /usr/bin/apt-mark manual $savedAptMark; \
        /usr/bin/ldd "$(/usr/local/bin/php -r 'echo ini_get("extension_dir");')"/*.so \
            | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
            | sort -u \
            | xargs -r dpkg-query --search \
            | cut -d: -f1 \
            | sort -u \
            | xargs -rt apt-mark manual; \
        \
        /usr/bin/apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*

    mkdir -p \
        /var/log/supervisord \
        /var/run/supervisord \
    ;
  '';
  config = {
    ENV = {
      NEXTCLOUD_UPDATE = 1;
    };
    CMD = [
      "/usr/bin/supervisord"
      "-c"
      # ./supervisord.conf
    ];

  };

}
# build: nextcloud-dockerfiles/full/apache/
