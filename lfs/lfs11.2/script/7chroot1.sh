#!/bin/bash
# chapter 7 before chroot

run_user=$(id -u -n)
if [ "$run_user" != "root" ];then
  echo "run as root user, current user $run_user"
  exit 1
fi

if [ -z "$LFS" ];then
  echo -e "LFS var is empty\nsource .bashrc\necho \$LFS"
  exit 1
fi

chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
 x86_64) chown -R root:root $LFS/lib64 ;;
esac

mkdir -pv $LFS/{dev,proc,sys,run}

mount -v --bind /dev $LFS/dev

mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
 mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

cat <<"EOF"
run below enter chroot:
chroot "$LFS" /usr/bin/env -i \
 HOME=/root \
 TERM="$TERM" \
 PS1='(lfs chroot) \u:\w\$ ' \
 PATH=/usr/bin:/usr/sbin \
 /bin/bash --login
EOF