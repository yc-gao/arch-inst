#!/bin/bash
set -e

hostname='xundaoxd-pc'
user="xundaoxd"

ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

sed -i 's/^#en_US.UTF-8/en_US.UTF-8/;s/^#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

cat > /etc/hostname << EOF
$hostname
EOF
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.0.1   $hostname.localdomain   $hostname
EOF

mkinitcpio -P

pacman -S --noconfirm grub efibootmgr
grub-install --efi-directory=/boot/efi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm nvidia alsa-utils alsa-firmware pulseaudio pulseaudio-alsa pulseaudio-bluetooth

useradd -m -s /bin/zsh $user
usermod -aG sudo $user

pacman -S --noconfirm plasma kde-applications
systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth

pacman -S --noconfirm docker
systemctl enable docker
usermod -aG docker xundaoxd

pacman -S --noconfirm firefox ttf-dejavu wqy-zenhei wqy-microhei man-db man-pages fcitx-googlepinyin kcm-fcitx git ttf-fira-code

echo 'set root password.'
passwd

echo "set $user password."
passwd $user
