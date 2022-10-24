
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


10.4 grub生成rescue iso
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


cd linux-5.19.2
make mrproper
make defconfig
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
