
# [Linux From Scratch](https://www.linuxfromscratch.org)

## LFS 11.2 安装指导

 - 需要下载pdf知道书，和软件包 package

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
