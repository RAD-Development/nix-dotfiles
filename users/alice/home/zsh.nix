{ ... }:
{

  programs.zsh = {

    enable = true;
    # autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "colored-man-pages"
        "rust"
        "systemd"
        "tmux"
        "ufw"
        "z"
        #"fzf"
      ];
    };
    initExtra = ''
      # functions
      function mount-data {
          if [[ -f /home/alice/backup/.noconnection ]]; then
      	sshfs -p 10934 lily@192.168.1.154:/mnt/backup/data/ ~/backup -C
          else
      	echo "Connection to backup server already open."
          fi
      }

      function mount-backup {
          if [[ -f /home/alice/backup/.noconnection ]]; then
          	sudo borgmatic mount --options allow_other,nonempty --archive latest --mount-point ~/backup -c /etc/borgmatic/config_checkless.yaml
          else
              echo "Connection to backup server already open."
          fi
      }

      function mount-ubuntu {
          if [[ -f /home/alice/backup/.noconnection ]]; then
              sshfs lily@192.168.76.101:/mnt/backup/ubuntu.old/ ~/backup -C
          else
              echo "Connection to backup server already open."
          fi
      }
    '';
    shellAliases = {
      "sgc" = "sudo git -C /root/dotfiles";
      ## SSH
      "ssh-init" = "ssh-add -t 24h ~/.ssh/id_ed25519_janus ~/.ssh/id_ed25519_dennis ~/.ssh/id_ed25519_hetzner ~/.ssh/id_rsa_tails ~/.ssh/id_ed25519_tails ~/.ssh/id_ed25519_gl ~/.ssh/id_ed25519_jeeves2 ~/.ssh/id_ed25519_jeeves ~/.ssh/id_rsa_palatine ~/.ssh/id_ed25519_palatine";

      ## Backups
      "borgmatic-backup-quick" = "sudo borgmatic --log-file-verbosity 2 -v1 --progress --log-file=/var/log/borgmatic.log -c /etc/borgmatic/config_checkless.yaml";
      "borgmatic-backup-full" = "sudo borgmatic --log-file-verbosity 2 -v1 --log-file=/var/log/borgmatic.log -c /etc/borgmatic/config_full_arch.yaml";
      "umount-backup" = "sudo borgmatic umount --mount-point /home/alice/backup -c /etc/borgmatic/config_checkless.yaml";
      "restic-backup" = "/home/alice/Scripts/restic/backup.sh";

      ## VPN
      "pfSense-vpn" = "sudo openvpn --config /etc/openvpn/client/pfSense-TCP4-1194-alice-config.ovpn";
      "pfSense-vpn-all" = "sudo openvpn --config /etc/openvpn/client/pfSense-TCP4-1195-alice-config.ovpn";

      ## Utilities
      "lrt" = "eza --icons -lsnew";
      "lynis-grep" = ''sudo lynis audit system 2&>1 | grep -v "egrep"'';
      "egrep" = "grep -E";
      "htgp" = "history | grep";
      "gen_walpaper" = "wal -i '/home/alice/Pictures/Wallpapers/1440pdump'";
      "vlgdf" = "valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes";
      "ls" = "eza --icons";
      "libreoffice-writer" = "libreoffice --writer";
      "libreoffice-calc" = "libreoffice --calc";
      "notes" = "code /home/alice/Scripts/Notes/dendron.code-workspace";
      "ua-drop-caches" = "sudo paccache -rk3; yay -Sc --aur --noconfirm";
      "ua-update-all" = ''
        (export TMPFILE="$(mktemp)"; \
              sudo true; \
              rate-mirrors --save=$TMPFILE --protocol https\
              --country-test-mirrors-per-country 10 arch --max-delay=21600 \
                && sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist-backup \
                && sudo mv $TMPFILE /etc/pacman.d/mirrorlist \
                && ua-drop-caches \
                && yay -Syyu)
      '';

      # applications (rofi entries)
      "ARMEclipse" = "nohup /opt/DS-5_CE/bin/eclipse &";
      "Wizard101-old" = "prime-run playonlinux --run Wizard\\ 101";
      "Wizard101" = "prime-run ~/.wine/drive_c/ProgramData/KingsIsle Entertainment/Wizard101/Wizard101.exe";
      "Pirate101" = "prime-run playonlinux --run Pirate\\ 101";
      "octave" = "prime-run octave --gui";
      "pc-firefox" = "proxychains firefox -P qbit -no-remote -P 127.0.0.1:9050";
      "hx" = "helix";
    };
  };
}
