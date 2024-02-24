#!/bin/bash
set -e

hostname="archiso"
echo $hostname > /etc/hostname

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
locale-gen

sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

systemctl enable NetworkManager
systemctl enable sshd
systemctl enable bluetooth
systemctl enable sddm

useradd -m -s /bin/zsh xundaoxd
usermod -aG wheel,input,video,audio,kvm xundaoxd
sed -E -i '/^#\s*%wheel.*NOPASSWD/{s/^#\s*//}' /etc/sudoers
echo -e "demo1234\ndemo1234" | passwd xundaoxd
echo -e "demo1234\ndemo1234" | passwd root

