#!/bin/bash
set -e

self_dir=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
proj_dir=$(dirname "$self_dir")

opt_wdir="$HOME/Workdir"
user="xundaoxd"

die() {
    echo "$@"
    exit 1
}

run_asroot() {
    sudo "$0" "$@"
}

aur() {
    if [[ $UID != 0 ]]; then
        git clone https://aur.archlinux.org/yay-bin.git
        (cd yay-bin && makepkg -si --noconfirm --needed)
        rm -rf yay-bin
    fi
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

custom() {
    git clone git@github.com:xundaoxd/dotfiles.git "${opt_wdir}/dotfiles"
    (cd "${opt_wdir}/dotfiles" && ./install.sh -f)
}

kde_desktop() {
    if [[ $UID != 0 ]]; then
        run_asroot kde_desktop
        return
    fi

    pacman -Syy
    pacman -S --noconfirm plasma-meta kde-applications-meta \
            kcm-fcitx fcitx-googlepinyin
    systemctl enable sddm

    pacman -S --noconfirm vlc firefox ffmpeg \
        man-db man-pages wget curl xclip ripgrep-all \
        ctags openbsd-netcat unzip neovim jq nmap rsync

    cp -r "${proj_dir}/airootfs/etc/modprobe.d" /etc/
    cp "${proj_dir}/airootfs/etc/sddm.conf" /etc/
    mkinitcpio -P
}

kde () {
    [[ $UID == 0 ]] && die "please init kde use $user"

    aur
    docker
    kde_desktop
    custom
}

action="kde"
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

