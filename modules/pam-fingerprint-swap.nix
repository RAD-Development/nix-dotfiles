{ config, lib, ... }:

# borrowed from https://github.com/NixOS/nixpkgs/issues/171136
# and https://wiki.archlinux.org/title/fprint#Login_configuration
# and also this internal/experimental feature:
# https://github.com/NixOS/nixpkgs/pull/255547
#
# This should allow fprintd to go after pam_unix (so it asks for your password first!)
let
  cfg = config.security.pam.fprintd-order;
in
{
  options = {
    security.pam.fprintd-order = {
      enable = lib.mkEnableOption "fprintd-order";
      order = lib.mkOption {
        type = lib.types.int;
        default = 11501;
        description = ''
          the ordering for fprintd used in pam.d service files.
          11300 is the current default as of 2024-04-02 (subject to change with auto-ordering rules)
          11501 places it just after pam_unix (ie. password prompt, then fingerprint)
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # to generate this its going to look something like this
    # rg "fprintd" --follow /etc/pam.d | sed -nr 's/\/etc\/pam.d\/(\w+)/\1/p' | cut -d ':' -f 1 | awk '{printf "security.pam.services.%s.rules.auth.fprintd.order=11501;\n",$1}'

    # need to check if this one is needed... file doesnt exist when this module is disabled
    #security.pam.services.auth.rules.auth.fprintd.order = cfg.order;
    security.pam.services = {
      passwd.rules.auth.fprintd.order = cfg.order;
      chpasswd.rules.auth.fprintd.order = cfg.order;
      groupdel.rules.auth.fprintd.order = cfg.order;
      groupadd.rules.auth.fprintd.order = cfg.order;
      useradd.rules.auth.fprintd.order = cfg.order;
      i3lock.rules.auth.fprintd.order = cfg.order;
      systemd-user.rules.auth.fprintd.order = cfg.order;
      sudo.rules.auth.fprintd.order = cfg.order;
      userdel.rules.auth.fprintd.order = cfg.order;
      chfn.rules.auth.fprintd.order = cfg.order;
      su.rules.auth.fprintd.order = cfg.order;
      usermod.rules.auth.fprintd.order = cfg.order;
      groupmems.rules.auth.fprintd.order = cfg.order;
      chsh.rules.auth.fprintd.order = cfg.order;
      i3lock-color.rules.auth.fprintd.order = cfg.order;
      xscreensaver.rules.auth.fprintd.order = cfg.order;
      xlock.rules.auth.fprintd.order = cfg.order;
      polkit-1.rules.auth.fprintd.order = cfg.order;
      vlock.rules.auth.fprintd.order = cfg.order;
      runuser-l.rules.auth.fprintd.order = cfg.order;
      groupmod.rules.auth.fprintd.order = cfg.order;
      runuser.rules.auth.fprintd.order = cfg.order;
    };
  };
}
