#!/bin/bash
# chapter 8

cd /sources
rm -rf man-pages-5.13
tar xf man-pages-5.13.tar.xz
cd man-pages-5.13

make prefix=/usr install

cd /sources
rm -rf iana-etc-20220812
tar xf iana-etc-20220812.tar.gz
cd iana-etc-20220812

cp services protocols /etc

cd /sources
rm -rf glibc-2.36
tar xf glibc-2.36.tar.xz
cd glibc-2.36

patch -Np1 -i ../glibc-2.36-fhs-1.patch

mkdir -v build
cd build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr \
 --disable-werror \
 --enable-kernel=3.2 \
 --enable-stack-protector=strong \
 --with-headers=/usr/include \
 libc_cv_slibdir=/usr/lib

make

cat <<"EOF"
run follow cmd:
make check

EOF
