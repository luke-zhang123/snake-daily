#!/bin/bash
# chapter 5.2-5.5

run_user=$(id -u -n)
if [ "$run_user" != "lfs" ];then
  echo "run as lfs user, current user $run_user"
  exit 1
fi

if [ -z "$LFS" ];then
  echo -e "LFS var is empty\nsource .bashrc\necho \$LFS"
  exit 1
fi

cd $LFS/sources/
rm -rf binutils-2.39
tar xf binutils-2.39.tar.xz
cd binutils-2.39

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

cd $LFS/sources/
rm -rf linux-5.19.2
tar xf linux-5.19.2.tar.xz
cd linux-5.19.2

make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

cd $LFS/sources/
rm -rf glibc-2.36
tar xf glibc-2.36.tar.xz
cd glibc-2.36

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
cat <<"EOF"
echo 'int main(){}' | gcc -xc -
readelf -l a.out | grep ld-linux

check output "[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]"
rm -v a.out

if OK, run below to finalize the installation
$LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders
EOF