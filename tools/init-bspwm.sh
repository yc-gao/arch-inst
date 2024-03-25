#!/bin/bash
set -e

self_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
proj_dir=$(dirname "$self_dir")

opt_wdir="$HOME/Workdir"
user="xundaoxd"

err() {
    echo "$@" >&2
}
die() {
    err "$@"
    exit 1
}

run_asroot() {
    sudo "$0" -w "${opt_wdir}" "$@"
}

base() {
    if [[ $UID != 0 ]]; then
        run_asroot base
        return
    fi
    pacman -Syu --noconfirm
}

aur() {
    git clone https://aur.archlinux.org/yay-bin.git
    (cd yay-bin && makepkg -si --noconfirm --needed)
    rm -rf yay-bin
}

docker() {
    if [[ $UID != 0 ]]; then
        run_asroot docker
        yay -S --noconfirm nvidia-container-toolkit
        rm -rf ~/go
        return
    fi
    pacman -Syy
    pacman -S --noconfirm docker docker-compose
    systemctl enable docker
    usermod -aG docker $user
}

bspwm_desktop() {
    if [[ $UID != 0 ]]; then
        run_asroot bspwm_desktop
        cp -r "${proj_dir}/airootfs/home/xundaoxd" /home/
        return
    fi

    pacman -Syy

    pacman -S --noconfirm pipewire wireplumber pipewire-audio pipewire-alsa \
        bluez bluez-utils
    systemctl enable bluetooth

    pacman -S --noconfirm xorg sddm xdotool xss-lock i3lock \
        bspwm sxhkd alacritty polybar rofi ranger feh flameshot
    systemctl enable sddm

    pacman -S --noconfirm fcitx-im fcitx-googlepinyin fcitx-configtool

    pacman -S --noconfirm vlc evince firefox obsidian \
        usbutils ffmpeg \
        man-db man-pages wget curl xclip ripgrep-all \
        ctags openbsd-netcat unzip neovim jq nmap rsync

    cp -r "${proj_dir}/airootfs/etc/modprobe.d" /etc/
    mkinitcpio -P
}

custom() {
    git clone git@github.com:xundaoxd/dotfiles.git "${opt_wdir}/dotfiles"
    (cd "${opt_wdir}/dotfiles" && ./install.sh -f)
}

bspwm() {
    [[ $UID == 0 ]] && die "please init bspwm use $user"

    base
    aur
    docker
    bspwm_desktop
    custom
}

action="bspwm"
while (($#)); do
    case $1 in
        -w)
            opt_wdir="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done
if (($#)); then
    action="$1"
    shift
fi
"${action}" "$@"

