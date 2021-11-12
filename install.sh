#!/usr/bin/env bash
set -Eeuo pipefail

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
    printf "$hostname" >/etc/hostname
    printf "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >/etc/locale.gen
    printf "LANG=en_US.UTF-8" >/etc/locale.conf

    ln -sfT /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    locale-gen

    # kernel
    mkinitcpio -P

    # nvidia
    pacman -S --noconfirm nvidia-open-lts

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
    btrfs subvol create "${targetfs}/snapshots/boot"
    ln -sT snapshots/boot "${targetfs}/rootfs"

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
        printf "UUID=%s         /swap       btrfs   defaults,subvol=swap    0    0\n" "$(lsblk -n -o uuid "${rootdisk}")"
        printf "/swap/swapfile  none        swap    defaults    0    0\n"
    } >"${targetfs}/etc/fstab"

    local grubmodules=(all_video at_keyboard boot btrfs cat chain configfile echo efifwsetup efinet exfat ext2 f2fs fat font \
        gfxmenu gfxterm gzio halt hfsplus iso9660 jpeg keylayouts linux loadenv loopback lsefi lsefimmap \
        minicmd normal ntfs ntfscomp part_apple part_gpt part_msdos png read reboot regexp search \
        search_fs_file search_fs_uuid search_label serial sleep tpm udf usb usbserial_common usbserial_ftdi \
        usbserial_pl2303 usbserial_usbdebug video xfs zstd)
    mkdir -p "${targetfs}/boot/efi/EFI/BOOT"
    grub-mkstandalone -O x86_64-efi \
        --modules="${grubmodules[*]}" \
        -o "${targetfs}/boot/efi/EFI/BOOT/BOOTx64.EFI" \
        "boot/grub/grub.cfg=grub/grub.embedded.cfg"
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
