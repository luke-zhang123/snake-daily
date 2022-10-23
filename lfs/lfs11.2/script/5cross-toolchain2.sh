#!/bin/bash
# chapter 5.6

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
rm -rf gcc-12.2.0
tar xf gcc-12.2.0.tar.xz
cd gcc-12.2.0

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