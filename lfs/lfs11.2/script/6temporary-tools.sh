#!/bin/bash
# chapter 6

run_user=$(id -u -n)
if [ "$run_user" != "lfs" ];then
  echo "run as lfs user, current user $run_user"
  exit 1
fi

if [ -z "$LFS" ];then
  echo -e "LFS var is empty\nsource .bashrc\necho \$LFS"
  exit 1
fi

if [ -z "$LFS_TGT" ];then
  echo -e "LFS_TGT var is empty\nsource .bashrc\necho \$LFS_TGT"
  exit 1
fi

cd $LFS/sources/
rm -rf m4-1.4.19
tar xf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

cd $LFS/sources/
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

cd $LFS/sources/
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

cd $LFS/sources/
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

cd $LFS/sources/
rm -rf diffutils-3.8
tar xf diffutils-3.8.tar.xz
cd diffutils-3.8

./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd $LFS/sources/
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

cd $LFS/sources/
rm -rf findutils-4.9.0
tar xf findutils-4.9.0.tar.xz
cd findutils-4.9.0

./configure --prefix=/usr \
 --localstatedir=/var/lib/locate \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf gawk-5.1.1
tar xf gawk-5.1.1.tar.xz
cd gawk-5.1.1

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf grep-3.7
tar xf grep-3.7.tar.xz
cd grep-3.7

./configure --prefix=/usr \
 --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf gzip-1.12
tar xf gzip-1.12.tar.xz
cd gzip-1.12

./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf make-4.3
tar xf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr \
 --without-guile \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf patch-2.7.6
tar xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf sed-4.8
tar xf sed-4.8.tar.xz
cd sed-4.8

./configure --prefix=/usr \
 --host=$LFS_TGT
make
make DESTDIR=$LFS install

cd $LFS/sources/
rm -rf tar-1.34
tar xf tar-1.34.tar.xz
cd tar-1.34

./configure --prefix=/usr \
 --host=$LFS_TGT \
 --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

cd $LFS/sources/
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

cd $LFS/sources/
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

cd $LFS/sources/
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
