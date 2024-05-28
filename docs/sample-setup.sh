#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#git --command bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

PROCEED="N"

################################################################################
#
# This script is a sample install script for using this repository
#
# This makes several assumptions, listed below
#    the system will use LVM for managing drives and snapshots
#    SOPS should be set up (set SOPS=N to disable)
#    this is a server (change GITBASE to reflect path to machine config)
#    this machine is called "machine"
#    this machine will have all partitions on /dev/sda
#    there will be no swap partition (set SWAPSIZE to non-zero)
#
# Please check the below variables and make changes as appropriate
#
################################################################################

# Need to validate the below before running the script
# Set SWAPSIZE to something larger than 0 to enable it
# (even if CREATEPARTS is disabled)
VOLGROUP="nixos-vg"
DRIVE="nvme0n1"
MACHINENAME="artemision"
SWAPSIZE="35G"

# Feature toggles (must be Y to be enabled)
CREATEPARTS="Y"
SOPS="Y"

# SOPS owner
OWNERORADMINS="alice"

# Partition planning
ROOTPATH="/dev/$VOLGROUP/root"
SWAPPATH="/dev/$VOLGROUP/swap"
HOMEPATH="/dev/$VOLGROUP/home"
NIXSTOREPATH="/dev/$VOLGROUP/nix"
BOOTPART="/dev/${DRIVE}p1"

# git vars
GITBASE="users/alice/systems"
FEATUREBRANCH="feature/$MACHINENAME"

if [ $PROCEED != "Y" ]; then
    echo "PROCEED is not set correctly, please validate the below partitions and update the script accordingly"
    lsblk -ao NAME,FSTYPE,FSSIZE,FSUSED,SIZE,MOUNTPOINT
fi



if [ $CREATEPARTS = "Y" ]; then
    # Create partition table
    sudo parted "/dev/$DRIVE" -- mklabel gpt

    # Create boot part
    sudo parted "/dev/$DRIVE" -- mkpart ESP fat32 1MB 1024MB
    sudo parted "/dev/$DRIVE" -- set 1 esp on
    sudo mkfs.fat -F 32 -n NIXBOOT "/dev/${DRIVE}1"

    # Create luks part
    sudo parted "/dev/$DRIVE" -- mkpart primary ext4 1024MB 100%
    sudo parted "/dev/$DRIVE" -- set 2 lvm on
    
    LUKSPART="nixos-pv"
    sudo cryptsetup luksFormat "/dev/${DRIVE}p2"
    sudo cryptsetup luksOpen "/dev/${DRIVE}p2" "$LUKSPART"

    # Create lvm part
    sudo pvcreate "/dev/mapper/$LUKSPART"
    sudo pvresize "/dev/mapper/$LUKSPART"
    sudo pvdisplay

    # Create volume group
    sudo vgcreate "$VOLGROUP" "/dev/mapper/$LUKSPART"
    sudo vgchange -a y "$VOLGROUP"
    sudo vgdisplay

    # Create swap part on LVM
    if [ $SWAPSIZE != 0 ]; then
        sudo lvcreate -L "$SWAPSIZE" "$VOLGROUP" -n swap
        sudo mkswap -L NIXSWAP -c "$SWAPPATH"
    fi

    # Create home part on LVM, leaving plenty of room for snapshots
    sudo lvcreate -l 50%FREE "$VOLGROUP" -n home
    sudo mkfs.ext4 -L NIXHOME -c "$HOMEPATH"

    # Create root part on LVM, keeping in mind most data will be on /home or /nix
    sudo lvcreate -L 5G "$VOLGROUP" -n root
    sudo mkfs.ext4 -L NIXROOT -c "$ROOTPATH"

    # Create nix part on LVM
    sudo lvcreate -L 100G "$VOLGROUP" -n nix-store
    sudo mkfs.ext4 -L NIXSTORE -c "$NIXSTOREPATH"

    sudo lvdisplay

    lsblk -ao NAME,FSTYPE,FSSIZE,FSUSED,SIZE,MOUNTPOINT
fi

# Mount partitions
sudo mount $ROOTPATH /mnt

sudo mkdir /mnt/{home,nix,boot} || echo "directories already exist (/mnt/{home,nix,boot})"
sudo mount $HOMEPATH /mnt/home
sudo mount $NIXSTOREPATH /mnt/nix
sudo mount $BOOTPART /mnt/boot

# Enable swap if SWAPSIZE is non-zero
if [ $SWAPSIZE != 0 ]; then
    sudo swapon "/dev/$VOLGROUP/swap"
fi

# Clone the repo
DOTS="/mnt/root/dotfiles"
GC="git -C $DOTS"
sudo mkdir -p "$DOTS" || echo "directory $DOTS already exists"
sudo $GC clone https://github.com/RAD-Development/nix-dotfiles.git .
sudo $GC checkout "$FEATUREBRANCH"

# Create ssh keys
sudo mkdir /root/.ssh
sudo chmod 700 /root/.ssh
sudo ssh-keygen -t ed25519 -o -a 100 -f "/root/.ssh/id_ed25519_ghdeploy" -q -N "" -C "$MACHINENAME" || echo "key already exists"

read -r -p "get this into github so you can check everything in, then hit enter :)"
cat "$DOTS/id_ed25519_ghdeploy.pub"

if [ $SOPS == "Y" ]; then
    # Create ssh host-keys
    sudo ssh-keygen -A
    sudo mkdir -p /mnt/etc/ssh
    sudo cp "/etc/ssh/ssh_host_*" /mnt/etc/ssh

    # Get line where AGE comment is and insert new AGE key two lines down
    AGELINE=$(grep "Generate AGE keys from SSH keys with" "$DOTS/.sops.yaml" -n | awk -F ':' '{print ($1+2)}')
    AGEKEY=$(nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age')
    sudo sed -i "${AGELINE}i\\  - &${MACHINENAME} $AGEKEY\\" "$DOTS/.sops.yaml"

    # Add server name
    SERVERLINE=$(grep 'servers: &servers' "$DOTS/.sops.yaml" -n | awk -F ':' '{print ($1+1)}')
    sudo sed -i "${SERVERLINE}i\\  - *${MACHINENAME}\\" "$DOTS/.sops.yaml"

    # Add creation rules
    CREATIONLINE=$(grep 'creation_rules' "$DOTS/.sops.yaml" -n | awk -F ':' '{print ($1+1)}')
    # TODO: below was not working when last attempted
    read -r -d '' PATHRULE <<-EOF
  - path_regex: $GITBASE/$MACHINENAME/secrets\.yaml$
    key_groups:
      - pgp: *$OWNERORADMINS
        age:
          - *$MACHINENAME
EOF
    sudo sed -i "${CREATIONLINE}i\\${PATHRULE}\\" "$DOTS/.sops.yaml"
fi

read -r -p "press enter to continue"

# generate hardware.nix
sudo nixos-generate-config --root /mnt --dir "$DOTS"
sudo mv "$DOTS/$GITBASE/$MACHINENAME/hardware{-configuration,}.nix"

# from https://nixos.org/manual/nixos/unstable

sudo nixos-install --flake "$DOTS#$MACHINENAME"

# add ssh config for root and reset git repo url
read -r -d '' SSHCONFIG <<-EOF
Host github.com
        User git
        Hostname github.com
        PreferredAuthentications publickey
        IdentityFile /root/.ssh/id_ed25519_ghdeploy
EOF
printf "%s" "$SSHCONFIG" | sudo tee /root/.ssh/config
sudo "$GC" remote set-url origin 'git@github.com:RAD-Development/nix-dotfiles.git'
