{
  config,
  lib,
  pkgs,
  ...
}:
{
  # custom module from modules/pam-fingerprint-swap.nix
  # swaps password and fingerprint in pam ordering
  security.pam.fprintd-order = {
    enable = false;
    order = 11501;
  };

  # to auto-flip to password when the laptop lid is closed (ie. docked)
  services.acpid = {
    enable = true;
    lidEventCommands = ''
      export PATH=$PATH:/run/current-system/sw/bin

      if grep -Fq closed /proc/acpi/button/lid/LID0/state; then
          ${pkgs.systemd}/bin/systemctl stop fprintd.service
          ${pkgs.coreutils}/bin/ln -s /dev/null /run/systemd/transient/fprintd.service
          ${pkgs.systemd}/bin/systemctl daemon-reload
      else
          ${pkgs.coreutils}/bin/rm -f /run/systemd/transient/fprintd.service
          ${pkgs.systemd}/bin/systemctl daemon-reload
          ${pkgs.systemd}/bin/systemctlstart fprintd.service
      fi
    '';
  };
}
