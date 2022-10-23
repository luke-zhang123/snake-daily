#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import pwd
import inspect
import argparse
import subprocess


def version_check():
    check_cmd = """
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
if [ -h /usr/bin/yacc ]; then
 echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
 echo yacc is `/usr/bin/yacc --version | head -n1`
else
 echo "yacc not found"
fi
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
if [ -h /usr/bin/awk ]; then
 echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
 echo awk is `/usr/bin/awk --version | head -n1`
else
 echo "awk not found"
fi
gcc --version | head -n1
g++ --version | head -n1
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
make_version=$(make -v 2>&1| grep -v 'command not found' |grep Make |awk '{print $3}'| cut -d'.' -f1)
if [ "$make_version" != 4 ];then
 echo "ERROR: make version $make_version, need version at least 4"
fi
patch --version | head -n1
echo Perl `perl -V:version`
python3 --version
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1 # texinfo version
xz --version | head -n1
echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
 then echo "g++ compilation OK";
 else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
"""
    if not os.path.exists('version-check.sh'):
        print('version-check.sh not fount, create and running ')
        with open('version-check.sh', 'w') as check_file:
            check_file.write(check_cmd)
    else:
        print('version-check.sh found, running')
    print('------ check result:')
    print(subprocess.check_output(['bash', 'version-check.sh'], stderr=subprocess.STDOUT).decode(), end='')
    print('------ check result end')
    print("if error, you may install command.\nyum install bison gcc gcc-c++ python3 automake perl byacc patch texinfo")


def prepare_partition():
    partition_cmd = """
#!/bin/bash
sdb1_check=$(ls /dev/sdb1)
if [ -z "$sdb1_check" ];then
    echo 'sdb1 not found, start partition sdb'
    echo -e "p\nn\np\n1\n\n\nw" |fdisk /dev/sdb
    ls /dev/sdb1
    mkfs.ext4 /dev/sdb1
else
    echo 'sdb1 found, skip partition'
fi

fstab_check=$(grep lfs /etc/fstab)
if [ -z "$fstab_check" ];then
    echo 'lfs not in /etc/fstab, add it'
    partition_uuid=$(lsblk -o NAME,UUID |grep sdb1 |awk '{print $2}')
    echo -e "\nUUID=$partition_uuid /lfs ext4 defaults 0 0" >> /etc/fstab
else
    echo 'lfs found in /etc/fstab'
fi

bashrc_check=$(grep LFS .bashrc)
if [ -z "$bashrc_check" ];then
    echo 'LFS not in .bashrc, add it'
    echo -e "\nexport LFS=/lfs" >> .bashrc
else
    echo 'LFS found in .bashrc'
fi
source .bashrc
echo "check LFS:$LFS"
if [ -z "$LFS" ];then
  echo 'variable LFS empty'
  exit 1
fi

mountpoint /lfs
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "try mount /dev/sdb1 to $LFS"
    mkdir -pv $LFS
    mount -v /dev/sdb1 $LFS
else
    echo "/dev/sdb1 mount to $LFS"
fi
"""
    if not os.path.exists('prepare-partition.sh'):
        print('prepare-partition.sh not fount, create and running ')
        with open('prepare-partition.sh', 'w') as check_file:
            check_file.write(partition_cmd)
    else:
        print('prepare-partition.sh found, running')
    print('------ partition result:')
    try:
        print(subprocess.check_output(['bash', 'prepare-partition.sh'], stderr=subprocess.STDOUT).decode(), end='')
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command:[ {} ]\nexit status: {}\noutput:{}".format(' '.join(e.cmd), e.returncode, e.output.decode()))
    print('------ partition result end')


def run_cmd(cmd_str):
    with open('lfs-tmp.sh', 'w') as check_file:
        check_file.write(cmd_str)
    try:
        print(subprocess.check_output(['bash', 'lfs-tmp.sh'], stderr=subprocess.STDOUT).decode(), end='')
    except subprocess.CalledProcessError as e:
        raise RuntimeError("command:[ {} ]\nexit status: {}\noutput:{}".format(' '.join(e.cmd), e.returncode, e.output.decode()))

def pkg_check():
    print('func {}'.format(inspect.stack()[0][3]))
    cmd_str = """
#!/bin/bash
tar xvf lfs-packages-11.2.tar -C $LFS/sources
mv $LFS/sources/11.2-rc1/* $LFS/sources/
ls $LFS/sources/
pushd $LFS/sources
 md5sum -c md5sums
popd
"""
    run_cmd(cmd_str)


def mkdir_lfs_user():
    cmd_str = """
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
 ln -sv usr/$i $LFS/$i
done
case $(uname -m) in
 x86_64) mkdir -pv $LFS/lib64 ;;
esac
mkdir -pv $LFS/tools
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo 'lfs:111111' |chpasswd
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
 x86_64) chown -v lfs $LFS/lib64 ;;
esac
"""
    run_cmd(cmd_str)

def lfs_rc():
    cmd_str = """
cat > /home/lfs/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\\u:\\w\\$ ' /bin/bash
EOF

cat > /home/lfs/.bashrc << "EOF"
set +h
umask 022
LFS=/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE

export MAKEFLAGS="-j$(nproc)"
EOF
"""
    run_cmd(cmd_str)

def check_lfs_var():
    env = os.environ
    if 'LFS' not in env:
        print('LFS not found in os env')
        exit(1)
    if 'LFS_TGT' not in env:
        print('LFS_TGT not found in os env')
        exit(1)

def check_lfs_usr():
    if pwd.getpwuid(os.getuid())[0] == 'lfs':
        print('run script with {}, use lfs'.format(pwd.getpwuid(os.getuid())[0]))
        exit(1)

def c5_2():
    check_lfs_var()
    check_lfs_usr()
    cmd_str = """
rm -rf /lfs/sources/binutils-2.39
tar xf /lfs/sources/binutils-2.39.tar.xz -C /lfs/sources/
cd /lfs/sources/binutils-2.39

mkdir -v build
cd build

../configure --prefix=$LFS/tools \
 --with-sysroot=$LFS \
 --target=$LFS_TGT \
 --disable-nls \
 --enable-gprofng=no \
 --disable-werror

make
make install
"""
    run_cmd(cmd_str)

def c5_3():
    cmd_str = """
rm -rf /lfs/sources/gcc-12.2.0
tar xf /lfs/sources/gcc-12.2.0.tar.xz -C /lfs/sources/
cd /lfs/sources/gcc-12.2.0

tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

case $(uname -m) in
 x86_64)
 sed -e '/m64=/s/lib64/lib/' \
 -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd build

../configure \
 --target=$LFS_TGT \
 --prefix=$LFS/tools \
 --with-glibc-version=2.36 \
 --with-sysroot=$LFS \
 --with-newlib \
 --without-headers \
 --disable-nls \
 --disable-shared \
 --disable-multilib \
 --disable-decimal-float \
 --disable-threads \
 --disable-libatomic \
 --disable-libgomp \
 --disable-libquadmath \
 --disable-libssp \
 --disable-libvtv \
 --disable-libstdcxx \
 --enable-languages=c,c++

make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
 `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
"""

def c5_4():
    cmd_str = """
rm -rf /lfs/sources/linux-5.19.2
tar xf /lfs/sources/linux-5.19.2.tar.xz -C /lfs/sources/
cd /lfs/sources/linux-5.19.2

make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr
"""

def c_5_5():
    cmd_str = """
rm -rf /lfs/sources/glibc-2.36
tar xf /lfs/sources/glibc-2.36.tar.xz -C /lfs/sources/
cd /lfs/sources/glibc-2.36

case $(uname -m) in
 i?86) ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
 ;;
 x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
 ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
 ;;
esac

patch -Np1 -i ../glibc-2.36-fhs-1.patch

mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure \
 --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(../scripts/config.guess) \
 --enable-kernel=3.2 \
 --with-headers=$LFS/usr/include \
 libc_cv_slibdir=/usr/lib

make
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

echo 'gcc test'
echo 'int main(){}' | gcc -xc -
check=$(readelf -l a.out | grep ld-linux | grep /lib64/ld-linux-x86-64.so.2)
if [ -z "$check" ];then
    echo 'gcc check failed'
    exit 1
fi
rm -v a.out

$LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders
"""

def c5_6():
    cmd_str = """
rm -rf /lfs/sources/gcc-12.2.0
tar xf /lfs/sources/gcc-12.2.0.tar.xz -C /lfs/sources/
cd /lfs/sources/gcc-12.2.0

mkdir -v build
cd build

../libstdc++-v3/configure \
 --host=$LFS_TGT \
 --build=$(../config.guess) \
 --prefix=/usr \
 --disable-multilib \
 --disable-nls \
 --disable-libstdcxx-pch \
 --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0

make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la
"""

def c6():
    cmd_str = """
cd /lfs/sources/
rm -rf m4-1.4.19
tar xf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf ncurses-6.3
tar xf ncurses-6.3.tar.gz
cd ncurses-6.3

sed -i s/mawk// configure

mkdir build
pushd build
 ../configure
 make -C include
 make -C progs tic
popd

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(./config.guess) \
 --mandir=/usr/share/man \
 --with-manpage-format=normal \
 --with-shared \
 --without-normal \
 --with-cxx-shared \
 --without-debug \
 --without-ada \
 --disable-stripping \
 --enable-widec

make

make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

cd /lfs/sources/
rm -rf bash-5.1.16
tar xf bash-5.1.16.tar.gz
cd bash-5.1.16

./configure --prefix=/usr \
 --build=$(support/config.guess) \
 --host=$LFS_TGT \
 --without-bash-malloc

make
make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh

cd /lfs/sources/
rm -rf coreutils-9.1
tar xf coreutils-9.1.tar.xz
cd coreutils-9.1

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess) \
 --enable-install-program=hostname \
 --enable-no-install-program=kill,uptime

make
make DESTDIR=$LFS install

mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

cd /lfs/sources/
rm -rf diffutils-3.8
tar xf diffutils-3.8.tar.xz
cd diffutils-3.8

./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf file-5.42
tar xf file-5.42.tar.gz
cd file-5.42

mkdir build
pushd build
 ../configure --disable-bzlib \
 --disable-libseccomp \
 --disable-xzlib \
 --disable-zlib
 make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la

cd /lfs/sources/
rm -rf findutils-4.9.0
tar xf findutils-4.9.0.tar.xz
cd findutils-4.9.0

./configure --prefix=/usr \
 --localstatedir=/var/lib/locate \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf gawk-5.1.1
tar xf gawk-5.1.1.tar.xz
cd gawk-5.1.1

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf grep-3.7
tar xf grep-3.7.tar.xz
cd grep-3.7

./configure --prefix=/usr \
 --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf gzip-1.12
tar xf gzip-1.12.tar.xz
cd gzip-1.12

./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf make-4.3
tar xf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr \
 --without-guile \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf patch-2.7.6
tar xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf sed-4.8
tar xf sed-4.8.tar.xz
cd sed-4.8

./configure --prefix=/usr \
 --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf tar-1.34
tar xf tar-1.34.tar.xz
cd tar-1.34

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf xz-5.2.6
tar xf xz-5.2.6.tar.xz
cd xz-5.2.6

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess) \
 --disable-static \
 --docdir=/usr/share/doc/xz-5.2.6
make
make DESTDIR=$LFS install

cd /lfs/sources/
rm -rf binutils-2.39
tar xf binutils-2.39.tar.xz
cd binutils-2.39

sed '6009s/$add_dir//' -i ltmain.sh

mkdir -v build
cd build

../configure \
 --prefix=/usr \
 --build=$(../config.guess) \
 --host=$LFS_TGT \
 --disable-nls \
 --enable-shared \
 --enable-gprofng=no \
 --disable-werror \
 --enable-64-bit-bfd
make
make DESTDIR=$LFS install

rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}

cd /lfs/sources/
rm -rf gcc-12.2.0
tar xf gcc-12.2.0.tar.xz
cd gcc-12.2.0

tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc

case $(uname -m) in
 x86_64)
 sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
 ;;
esac

sed '/thread_header =/s/@.*@/gthr-posix.h/' \
 -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

mkdir -v build
cd build

../configure \
 --build=$(../config.guess) \
 --host=$LFS_TGT \
 --target=$LFS_TGT \
 LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
 --prefix=/usr \
 --with-build-sysroot=$LFS \
 --enable-initfini-array \
 --disable-nls \
 --disable-multilib \
 --disable-decimal-float \
 --disable-libatomic \
 --disable-libgomp \
 --disable-libquadmath \
 --disable-libssp \
 --disable-libvtv \
 --enable-languages=c,c++
make
make DESTDIR=$LFS install

ln -sv gcc $LFS/usr/bin/cc

"""
    run_cmd(cmd_str)


action_map = {
    "version-check": version_check,
    "prepare-partition": prepare_partition,

    "c6": c6
}

if __name__ == '__main__':
    print('start')

    parser = argparse.ArgumentParser('lfs python script')
    parser.add_argument('-a', '--action', nargs='+', dest='name', required=True)
    args = parser.parse_args()

    print("action:{}\n".format(args.name))

    for action_one in args.name:
        if action_one in action_map:
            print('run action [{}]:'.format(action_one))
            action_map[action_one]()
            print('action end ------')
            print()
        else:
            print('action [{}] not found in action_map'.format(action_one))
            exit(1)

