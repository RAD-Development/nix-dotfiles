{ config, pkgs, lib, ... }:

let
  cfg = config.mailserver;
  commonLdapConfig = lib.optionalString (cfg.ldap.enable) ''
    server_host = ${lib.concatStringsSep " " cfg.ldap.uris}
    start_tls = ${if cfg.ldap.startTls then "yes" else "no"}
    version = 3
    tls_ca_cert_file = ${cfg.ldap.tlsCAFile}
    tls_require_cert = yes

    search_base = ${cfg.ldap.searchBase}
    scope = ${cfg.ldap.searchScope}

    bind = yes
    bind_dn = ${cfg.ldap.bind.dn}
    bind_pw = ${cfg.ldap.bind.password}
  '';

  ldapVirtualMailboxDomains = lib.optionalString (cfg.ldap.enable)
    (pkgs.writeText "ldap-virtual-mailbox-domains.cf" ''
      ${commonLdapConfig}
      query_filter = (&(objectclass=groupOfNames)(entryDN:dn:=cn=maildomains,ou=mail,ou=services,dc=XXX,dc=net)(member=cn=%s))
      result_attribute = cn
    '');

  ldapVirtualAliasMap = lib.optionalString (cfg.ldap.enable)
    (pkgs.writeText "ldap-virtual-alias-map.cf" ''
      ${commonLdapConfig}
      query_filter = (&(objectclass=person)(mailLocalAddress=%s))
      result_attribute = mail
    '');
in
{
  # TODO: inspect
  # services.postfix.config = {
  #   virtual_mailbox_domains = lib.mkForce "ldap:${ldapVirtualMailboxDomains}";
  #   virtual_alias_maps = "ldap:${ldapVirtualAliasMap}";
  # };

  services.dovecot2.sieve.extensions = [ "fileinto" "copy" ];
  mailserver = {
    enable = true;
    fqdn = "mail.wavelens.io";
    domains = [ "wavelens.io" ];
    certificateScheme = "acme-nginx";
    indexDir = "/var/lib/dovecot/indices";
    openFirewall = false;

    fullTextSearch = {
      enable = true;
      autoIndex = true;
      indexAttachments = true;
      enforced = "body";
    };

    loginAccounts = {
      "info@wavelens.io" = {
        hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-info".path;
        aliases = [ "hey@wavelens.io" ];
      };

      "catch@wavelens.io" = {
        hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-catch".path;
        catchAll = [ "wavelens.io" ];
        aliases = [ "security@wavelens.io" ];
      };

      "dennis.wuitz@wavelens.io".hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-dennis".path;
    } // (builtins.listToAttrs (map
      (name: {
        name = "${name}@wavelens.io";
        value = {
          hashedPasswordFile = config.sops.secrets."mailserver/mail-passwords/wavelens-${name}".path;
          sendOnly = true;
        };
      }) [ "noreply" "git" "wiki" "vault" ]));

    ldap = {
      enable = false;
      uris = [ "ldaps://${config.services.portunus.domain}" ];
      searchBase = "dc=wavelens,dc=io";
      searchScope = "sub";

      bind = {
        dn = "uid=${config.services.portunus.ldap.searchUserName}";
        passwordFile = config.sops.secrets."mailserver/ldap-password".path;
      };

      dovecot = {
        userFilter = "(&(objectclass=person)(isMemberOf=cn=mail-account,ou=groups,dc=wavelens,dc=io)(mail=%u))";
        passFilter = "(&(objectclass=person)(mail=%u))";
      };

      postfix = {
        mailAttribute = "mail";
        uidAttribute = "mail";
        filter = "(&(objectclass=person)(mail=%s))";
      };
    };
  };
}
