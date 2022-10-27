
# [Linux From Scratch](https://www.linuxfromscratch.org)

完全从源码，一步步编译生成一个linux系统，可以更深入了解linux系统内部依赖和系统构建过程

## LFS 11.2 安装指导

 - 需要下载 pdf 指导书，和软件包 package

[LFS-BOOK-11.2.pdf](https://www.linuxfromscratch.org/lfs/downloads/11.2/LFS-BOOK-11.2.pdf)

[lfs-packages-11.2.tar](https://mirror.download.it/lfs/pub/lfs/lfs-packages/lfs-packages-11.2.tar)


- vmware虚拟机centos7测试环境

centos 7.9.2009 minimal 最小安装

添加虚拟硬盘 CentOS7-lfs-30GB.vmdk

- 安装依赖软件，执行安装命令脚本

`yum install bison gcc gcc-c++ python3 automake perl byacc patch texinfo`

texinfo包含makeinfo

gcc-c++就是g++

byacc是yacc

后面 glibc 的 configure 需要make 4.0版本，安装make 4.2
```
yum install centos-release-scl-rh
yum install devtoolset-7-make
mv /usr/bin/make /usr/bin/make_bak
ln -s /opt/rh/devtoolset-7/root/usr/bin/make /usr/bin/make
make -v
```

root 执行本机软件检查，分区，默认新加硬盘位 sdb

python3 lfs11.2.py -a version-check prepare-partition

第5章的安装命令在 lfs11.2.py 里的 c5_2 函数内，表示第5.2节安装命令

lfs 执行第6章安装

python3 lfs11.2.py -a c6

c7.sh 是第7章

c8.sh 是第8章

注：可以打开上面的脚本，都是shell脚本，根据pdf里面的说明，逐个执行安装

用脚本安装

yum install bison gcc gcc-c++ python3 automake perl byacc patch texinfo -y
yum install centos-release-scl-rh -y
yum install devtoolset-7-make -y
mv /usr/bin/make /usr/bin/make_bak
ln -s /opt/rh/devtoolset-7/root/usr/bin/make /usr/bin/make
make -v

bash 1version-check.sh
bash 2partition-sdb.sh
source .bashrc
ls lfs-packages-11.2.tar
bash 3pkg.sh
ls $LFS/sources
bash 4mkdir-lfs-user.sh

su - lfs
bash 5cross-toolchain.sh
中间有一个gcc测试
bash 6temporary-tools.sh

exit 到root用户
bash 7chroot1.sh
chroot "$LFS" /usr/bin/env -i \
 HOME=/root \
 TERM="$TERM" \
 PS1='(lfs chroot) \u:\w\$ ' \
 PATH=/usr/bin:/usr/sbin \
 MAKEFLAGS="-j$(nproc)" \
 /bin/bash --login

bash 7chroot2.sh
完成后执行最后的语句，重新登陆bash，执行剩余命令
bash 7chroot3.sh
执行最后的清理

8lfs-system1.sh


10.4 grub生成rescue iso，xorriso命令在libisoburn，上面两个是依赖包
https://files.libburnia-project.org/releases/libburn-1.5.4.tar.gz
./configure --prefix=/usr --disable-static
make
make install

https://files.libburnia-project.org/releases/libisofs-1.5.4.tar.gz
./configure --prefix=/usr --disable-static
make
make install


https://www.linuxfromscratch.org/blfs/view/11.2/multimedia/libisoburn.html
https://files.libburnia-project.org/releases/libisoburn-1.5.4.tar.gz

./configure --prefix=/usr              \
            --disable-static           \
            --enable-pkg-check-modules
make
make install

make distclean
make mrproper
make defconfig
make allyesconfig

cd linux-5.19.2
make mrproper
make defconfig
make localmodconfig
make menuconfig
make
make modules_install

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.19.2-lfs-11.2
cp -iv System.map /boot/System.map-5.19.2
cp -iv .config /boot/config-5.19.2



cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5
insmod ext4
set root=(hd0,1)
menuentry "GNU/Linux, Linux 5.19.2-lfs-11.2" {
 linux /boot/vmlinuz-5.19.2-lfs-11.2 root=/dev/sdb1 ro
}
EOF

vmware启动到硬件，改成 第二磁盘启动，报错

Kernel Panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)

暂时没有解决

lsblk -o name,uuid

cp /boot/vmlinuz-3.10.0-1160.71.1.el7.x86_64 .
cp /boot/initramfs-3.10.0-1160.71.1.el7.x86_64.img .

grub-install --target=i386-pc /dev/sdb
grub-mkconfig -o /boot/grub/grub.cfg

menuentry 'CentOS Linux (vmlinuz-5.19.2-lfs-11.2) 7 (Core)' {
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod ext2
        
        search --no-floppy --fs-uuid --set=root 6a130d74-2980-4ac9-8ba3-6d8b5bda042e

        linux16 /boot/vmlinuz-5.19.2-lfs-11.2 LANG=en_US.UTF-8
        initrd16 /boot/initramfs-3.10.0-1160.71.1.el7.x86_64.img
}


vmlinuz-5.19.2-lfs-11.2




set default=0
set timeout=5

menuentry "GNU/Linux, Linux 5.19.2-lfs-11.2" {
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod ext2

        search --no-floppy --fs-uuid --set=root 6a130d74-2980-4ac9-8ba3-6d8b5bda042e
        linux /boot/vmlinuz-5.19.2-lfs-11.2 root=/dev/sdb1
}

menuentry 'CentOS Linux (3.10.0-1160.71.1.el7.x86_64) 7 (Core)' {
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod ext2

        search --no-floppy --fs-uuid --set=root 6a130d74-2980-4ac9-8ba3-6d8b5bda042e

        linux16 /boot/vmlinuz-3.10.0-1160.71.1.el7.x86_64 LANG=en_US.UTF-8
        initrd16 /boot/initramfs-3.10.0-1160.71.1.el7.x86_64.img
}

menuentry 'CentOS Linux (vmlinuz-5.19.2-lfs-11.2) 7 (Core)' {
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod ext2

        search --no-floppy --fs-uuid --set=root 6a130d74-2980-4ac9-8ba3-6d8b5bda042e

        linux16 /boot/vmlinuz-5.19.2-lfs-11.2 LANG=en_US.UTF-8
        initrd16 /boot/initramfs-3.10.0-1160.71.1.el7.x86_64.img
}

```
mkdir -p root
cd root
mkdir -p bin dev etc lib mnt proc sbin sys tmp var
cd -

curl -L 'https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox' >root/bin/busybox
chmod +x root/bin/busybox

root/bin/busybox --install root/bin/
ls root/bin/

cat >>root/init << EOF
#!/bin/busybox sh

mount -t devtmpfs  devtmpfs  /dev
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t tmpfs     tmpfs     /tmp

mknod -m 600 /dev/console c 5 1
mknod -m 666 /dev/null c 1 3

sh
EOF

cd root
find . | cpio -ov --format=newc | gzip -9 >../initramfz
cd -

cp initramfz /lfs/boot/initramfs-5.19.2-lfs-11.2.img
```


mount -v --bind /dev $LFS/dev

mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

chroot "$LFS" /usr/bin/env -i \
 HOME=/root \
 TERM="$TERM" \
 PS1='(lfs chroot) \u:\w\$ ' \
 PATH=/usr/bin:/usr/sbin \
 MAKEFLAGS="-j$(nproc)" \
 /bin/bash --login


[root@c7 ~]# lsmod |grep scsi
scsi_transport_spi     30732  1 mptspi
mptscsih               40150  1 mptspi
mptbase               106036  2 mptspi,mptscsih
[root@c7 ~]# cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: VMware,  Model: VMware Virtual S Rev: 1.0
  Type:   Direct-Access                    ANSI  SCSI revision: 02
Host: scsi0 Channel: 00 Id: 01 Lun: 00
  Vendor: VMware,  Model: VMware Virtual S Rev: 1.0
  Type:   Direct-Access                    ANSI  SCSI revision: 02
Host: scsi2 Channel: 00 Id: 00 Lun: 00
  Vendor: NECVMWar Model: VMware IDE CDR10 Rev: 1.00
  Type:   CD-ROM                           ANSI  SCSI revision: 05
[root@c7 ~]#


(lfs chroot) root:/# lsmod |grep -E 'scsi|mptspi'
mptspi                 22673  3
scsi_transport_spi     30732  1 mptspi
mptscsih               40150  1 mptspi
mptbase               106036  2 mptspi,mptscsih


dmesg -T |less
scsi
ata_piix

awk '{ print $1 }' /proc/modules | xargs modinfo -n | sort |grep -E 'drivers/scsi|drivers/ata|drivers/message/fusion'

awk '{ print $1 }' /proc/modules | xargs modinfo -n | sort |xargs -i cp --parents {} .
for MODULE in $(find /lib/modules/$(uname -r)/kernel -name '*.ko' -exec basename '{}' .ko ';')
do
    echo "Loading $MODULE"
    modprobe -D $MODULE
    modprobe $MODULE
    ls /dev/sd* 2>&1
    if [ $? -eq 0 ]; then
        echo 'find /dev/sd*'
        ls /dev/sd*
        exit 0
    else
        echo '/dev/sd* not found'
    fi
done


cd root/
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/ata/ata_generic.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/ata/ata_piix.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/ata/libata.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/ata/pata_acpi.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/message/fusion/mptbase.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/message/fusion/mptscsih.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/message/fusion/mptspi.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/scsi/scsi_transport_spi.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/scsi/sd_mod.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/scsi/sg.ko.xz ./
cp --parents /lib/modules/3.10.0-1160.71.1.el7.x86_64/kernel/drivers/scsi/sr_mod.ko.xz ./


message/fusion/mptbase
message/fusion/mptscsih
scsi/scsi_transport_spi
message/fusion/mptspi

ata/libata
ata/ata_piix  #cdrom

进入initramfs
depmod 生成mod依赖库, modprobe会自动加载依赖
modprobe mptspi
modprobe ata_piix
modprobe sd_mod


sd_mod -> "SCSI disk support"
sr_mod -> "SCSI CD_ROM Support"

Ubuntu系统无法进入Grub引导界面
https://blog.csdn.net/u013685264/article/details/125279731
内核编译选配（VMware篇）
https://www.cnblogs.com/sysk/p/4987698.html


exec switch_root -c /dev/console /new_root /sbin/init

