#!/bin/bash
fdisk /dev/nvme0n1

mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkfs.btrfs /dev/nvme0n1p3 -f

mount /dev/nvme0n1p3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

umount /mnt

mount -o rw,noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,autodefrag,subvol=@ /dev/nvme0n1p3 /mnt
mkdir -p /mnt/{boot,home}
mount -o rw,noatime,compress=zstd:1,ssd,discard=async,space_cache=v2,autodefrag,subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o rw,noatime /dev/nvme0n1p2 /mnt/boot
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

pacstrap -K /mnt base base-devel linux linux-firmware linux-headers amd-ucode intel-ucode git btrfs-progs grub efibootmgr grub-btrfs network-manager-applet dialog wpa_supplicant mtools dosfstools ntfs-3g inotify-tools timeshift vim networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber reflector openssh man sudo xdg-user-dirs xdg-utils bluez bluez-utils cups bash-completion openssh rsync acpi acpi_call firewalld flatpak sof-firmware nss-mdns acpid os-prober terminus-font

genfstab -U /mnt >> /mnt/etc/fstab

cp -r ~/arch-install /mnt/

arch-chroot /mnt
