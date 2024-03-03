#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash git

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
#    there will be no swap partition (set SWIPSZIE to non-zero)
#
# Please check the below variables and make changes as appropriate
#
################################################################################

# Need to validate the below before running the script
# Set SWAPSIZE to something larger than 0 to enable it
# (even if CREATEPARTS is disabled)
VOLGROUP="lvmgroup"
DRIVE="sda"
MACHINENAME="machine"
SWAPSIZE="0"

CREATEPARTS="N"
SOPS="Y"

OWNERORADMINS="admins"

ROOTPATH="/dev/$VOLGROUP/root"
SWAPPATH="/dev/$VOLGROUP/swap"
BOOTPART="/dev/${DRIVE}1"

GITBASE="systems"
FEATUREBRANCH="feature/adding-$MACHINENAME"

if [ $PROCEED != "Y" ]; then
    echo "PROCEED is not set correctly, please validate the below partitions and update the script accordingly"
    lsblk -ao NAME,FSTYPE,FSSIZE,FSUSED,SIZE,MOUNTPOINT
fi



if [ $CREATEPARTS != "Y" ]; then
    # Create partition table
    sudo parted "/dev/$DRIVE" -- mklabel gpt

    # Create boot part
    sudo parted "/dev/$DRIVE" -- mkpart ESP fat32 1MB 1024MB
    sudo parted "/dev/$DRIVE" -- set 1 esp on
    sudo mkfs.fat -F 32 -n NIXBOOT "/dev/${DRIVE}1"

    # Create lvm part
    sudo pvcreate "/dev/${DRIVE}2"
    sudo pvresize "/dev/${DRIVE}2"
    sudo pvdisplay

    # Create volume group
    sudo vgcreate "$VOLGROUP" "/dev/${DRIVE}2"
    sudo vgchange -a y "$VOLGROUP"
    sudo vgdisplay

    # Create swap part on LVM
    if [ $SWAPSIZE != 0 ]; then
        sudo lvcreate -L "$SWAPSIZE" "$VOLGROUP" -n swap
        sudo mkswap -L NIXSWAP -c "$SWAPPATH"
    fi

    # Create root part on LVM
    sudo lvcreate -l 100%FREE "$VOLGROUP" -n root
    sudo mkfs.ext4 -L NIXROOT -c "$ROOTPATH"
    sudo lvdisplay

    lsblk -ao NAME,FSTYPE,FSSIZE,FSUSED,SIZE,MOUNTPOINT
fi

# Mount partitions
sudo mount $ROOTPATH /mnt
sudo mount $BOOTPART /mnt/boot

# Enable swap if SWAPSIZE is non-zero
if [ $SWAPSIZE != 0 ]; then
    sudo swapon "/dev/$VOLGROUP/swap"
fi

# Clone the repo
DOTS="/root/dotfiles"
GC="git -C $DOTS"
sudo mkdir -p "$DOTS"
sudo "$GC" clone https://github.com/RAD-Development/nix-dotfiles.git .
sudo "$GC" checkout "$FEATUREBRANCH"

# Create ssh keys
ssh-keygen -t ed25519 -o -a 100 -f "$DOTS/id_ed25519_ghdeploy" -q -N "" -C "$MACHINENAME"

echo "get this into github so you can check everything in :)"
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
    read -r -d '' PATHRULE <<-EOF
  - path_regex: $GITBASE/$MACHINENAME/secrets\.yaml$
    key_groups:
      - pgp: *$OWNERORADMINS
        age:
          - *$MACHINENAME
EOF
    sudo sed -i "${CREATIONLINE}i\\${PATHRULE}\\" "$DOTS/.sops.yaml"
fi

echo "press enter to continue"
read -r ""

# generate hardware.nix
sudo nixos-generate-config --root /mnt --dir "$DOTS"
sudo mv "$DOTS/$GITBASE/$MACHINENAME/hardware{-configuration,}.nix"

# from https://nixos.org/manual/nixos/unstable

sudo nixos-install --flake "$DOTS#$MACHINENAME"
