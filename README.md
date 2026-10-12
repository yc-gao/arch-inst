# root disk layout

- disk
    - swap *
        - swapfile
    - rootfs  -> snapshots/main
    - snapshots
        - boot
            - boot/efi
        - main *

1. wifi setup
    nmcli device wifi
    nmcli device wifi conn demo-wifi password demo1234
2. bspwm setup
    git clone https://github.com/yc-gao/arch-inst $HOME/Workdir/arch-inst
    (cd $HOME/Workdir/arch-inst && ./bspwm.sh)

3. edisk setup, fstab setup
    lslkb -o name,uuid
    fstab: UUID=123556e4-12b5-4f12-b69f-29723259eb43   /mnt/edisk  ext4    defaults    0   0
    sudo mkdir -p /mnt/edisk && sudo mount -a
4. fonts&ssh setup
    tar -xvf /mnt/edisk/backup/fonts-pack.tar -C $HOME/.local/share
    tar -xvf /mnt/edisk/backup/ssh.tar -C $HOME && mv $HOME/ssh $HOME/.ssh
5. bspwm setup
    rm -rf $HOME/Workdir/arch-inst && git clone git@github.com:yc-gao/arch-inst $HOME/Workdir/arch-inst

6. autorandr setup
7. fcitx5 setup
8. docker-apps setup
    cat /mnt/edisk/images/mllab.docker.tar | podman import -
    git clone git@github.com:yc-gao/docker-apps $HOME/Workdir/docker-apps
    zshrc: add_local "$HOME"/Workdir/docker-apps
