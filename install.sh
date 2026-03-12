#!/usr/bin/env bash
set -euo pipefail

script_dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
script_name="$(basename "${BASH_SOURCE[0]}")"

info() {
    echo "Info: $*"
}

error() {
    echo "Error: $*" >&2
}

die() {
    error "Error: $*"
    exit 1
}

hostname='ycgao-pc'
user="ycgao"
user_passwd=

espdisk="/dev/nvme0n1p1"
rootdisk="/dev/nvme0n1p2"
targetfs="/mnt/target"

do_install() {
    printf "$hostname" > /etc/hostname
    printf "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" > /etc/locale.gen
    printf "LANG=en_US.UTF-8" > /etc/locale.conf

    ln -sfT /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    locale-gen

    # kernel
    mkinitcpio -P

    # boot
    pacman -S --noconfirm grub efibootmgr
    grub-install --efi-directory=/boot/efi --recheck

    # nvidia
    pacman -S --noconfirm nvidia-lts

    # network
    pacman -S --noconfirm networkmanager
    systemctl enable NetworkManager

    # misc and account
    pacman -S --noconfirm polkit sudo zsh git

    useradd -m -s /bin/zsh "${user}"
    usermod -aG wheel "${user}"
    sed -E -i 's/#\s*(%wheel\s+ALL=\(ALL:ALL\)\s+ALL)/\1/' /etc/sudoers
    printf "${user}:${user_passwd}" | chpasswd

    pacman -S --noconfirm openssh
    systemctl enable sshd
}

prepare() {
    # prepare disk
    mkfs.fat -F32 "${espdisk}"
    mkfs.btrfs -f -L rootdisk "${rootdisk}"

    mount --mkdir "${rootdisk}" "${targetfs}"

    btrfs subvol create "${targetfs}/swap"
    btrfs filesystem mkswapfile --size 128g "${targetfs}/swap/swapfile"

    mkdir -p "${targetfs}/snapshots"
    btrfs subvol create "${targetfs}/snapshots/boot_0"
    ln -sT snapshots/boot_0 "${targetfs}/rootfs"

    umount -R "${targetfs}"

    # install system
    mount -o subvol=rootfs "${rootdisk}" "${targetfs}"
    mount --mkdir "${espdisk}" "${targetfs}/boot/efi"

    pacstrap "${targetfs}" \
        base base-devel \
        linux-lts linux-firmware \
        btrfs-progs exfatprogs
    cp "${script_dir}/${script_name}" "${targetfs}/root/"
    arch-chroot "${targetfs}" "/root/${script_name}" do_install
    rm -rf "${targetfs}/root/${script_name}"

    {
        printf "UUID=%s\t/boot/efi\tvfat\tdefaults\t0\t2\n" "$(lsblk -n -o uuid "${espdisk}")"
        printf "UUID=%s\t/swap\tbtrfs\tdefaults,subvol=swap\t0\t0\n" "$(lsblk -n -o uuid "${rootdisk}")"
        printf "/swap/swapfile\tnone\tswap\tdefaults\t0\t0\n"
    } > "${targetfs}/etc/fstab"

    mkdir -p "${targetfs}/boot/grub"
    cp "${script_dir}/grub/grub.boot.cfg" "${targetfs}/boot/grub/grub.cfg"
    umount -R "${targetfs}"

    # install real grub
    "${script_dir}/rmanager" checkout boot_1
    mount -o subvol=rootfs "${rootdisk}" "${targetfs}"
    cp "${script_dir}/grub/grub.cfg" "${targetfs}/boot/grub/grub.cfg"
    umount -R "${targetfs}"
    "${script_dir}/rmanager" checkout main
}

actions=("prepare")
if (( $# > 0 )); then
    actions=("$@")
fi

for action in "${actions[@]}"; do
    if ! declare -f "${action}" > /dev/null; then
        die "function '${action}' not found"
    fi
    "${action}"
done