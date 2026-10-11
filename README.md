# root disk layout

- disk
    - swap *
        - swapfile
    - rootfs  -> snapshots/main
    - snapshots
        - boot
            - boot/efi
        - main *

1. edisk setup, fstab setup
2. autorandr setup
3. fcitx5 setup
4. fonts&ssh setup
    tar -xvf /mnt/edisk/backup/fonts-pack.tar -C $HOME/.local/share
    tar -xvf /mnt/edisk/backup/ssh.tar -C $HOME && mv $HOME/ssh $HOME/.ssh
    git config --global user.name ycgao
    git config --global user.email yc_x@outlook.com
5. docker-apps setup
    cat /mnt/edisk/images/mllab.docker.tar | podman import -
    git clone https://github.com/yc-gao/docker-apps.git $HOME/Workdir/docker-apps
    zshrc: add_local "$HOME"/Workdir/docker-apps
