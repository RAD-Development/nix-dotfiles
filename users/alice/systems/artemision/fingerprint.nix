{
  config,
  lib,
  pkgs,
  ...
}:

# borrowed from https://github.com/NixOS/nixpkgs/issues/171136
# and https://wiki.archlinux.org/title/fprint#Login_configuration
# and also this internal/experimental feature:
# https://github.com/NixOS/nixpkgs/pull/255547
#
# This should allow fprintd to go after pam_unix (so it asks for your password first!)
{

  # to generate this its going to look something like this
  # rg "fprintd" --follow /etc/pam.d | sed -nr 's/\/etc\/pam.d\/(\w+)/\1/p' | cut -d ':' -f 1 | awk '{printf "security.pam.services.%s.rules.auth.fprintd.order=11501;\n",$1}'
  security.pam.services.passwd.rules.auth.fprintd.order = 11501;
  security.pam.services.auth.rules.auth.fprintd.order = 11501;
  security.pam.services.chpasswd.rules.auth.fprintd.order = 11501;
  security.pam.services.groupdel.rules.auth.fprintd.order = 11501;
  security.pam.services.groupadd.rules.auth.fprintd.order = 11501;
  security.pam.services.useradd.rules.auth.fprintd.order = 11501;
  security.pam.services.i3lock.rules.auth.fprintd.order = 11501;
  security.pam.services.systemd-user.rules.auth.fprintd.order = 11501;
  security.pam.services.sudo.rules.auth.fprintd.order = 11501;
  security.pam.services.userdel.rules.auth.fprintd.order = 11501;
  security.pam.services.chfn.rules.auth.fprintd.order = 11501;
  security.pam.services.su.rules.auth.fprintd.order = 11501;
  security.pam.services.usermod.rules.auth.fprintd.order = 11501;
  security.pam.services.groupmems.rules.auth.fprintd.order = 11501;
  security.pam.services.chsh.rules.auth.fprintd.order = 11501;
  security.pam.services.i3lock-color.rules.auth.fprintd.order = 11501;
  security.pam.services.xscreensaver.rules.auth.fprintd.order = 11501;
  security.pam.services.xlock.rules.auth.fprintd.order = 11501;
  security.pam.services.polkit-1.rules.auth.fprintd.order = 11501;
  security.pam.services.vlock.rules.auth.fprintd.order = 11501;
  security.pam.services.runuser-l.rules.auth.fprintd.order = 11501;
  security.pam.services.groupmod.rules.auth.fprintd.order = 11501;
  security.pam.services.runuser.rules.auth.fprintd.order = 11501;
}
