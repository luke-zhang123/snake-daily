#!/bin/bash
# chapter 8

cd /sources
rm -rf zlib-1.2.12
tar xf zlib-1.2.12.tar.xz
cd zlib-1.2.12

./configure --prefix=/usr
make
make install

rm -fv /usr/lib/libz.a

cd /sources
rm -rf bzip2-1.0.8
tar xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

make -f Makefile-libbz2_so
make clean

make
make PREFIX=/usr install

cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
 ln -sfv bzip2 $i
done

rm -fv /usr/lib/libbz2.a

cd /sources
rm -rf xz-5.2.6
tar xf xz-5.2.6.tar.xz
cd xz-5.2.6

./configure --prefix=/usr \
 --disable-static \
 --docdir=/usr/share/doc/xz-5.2.6
make
make install

cd /sources
rm -rf zstd-1.5.2
tar xf zstd-1.5.2.tar.gz
cd zstd-1.5.2

patch -Np1 -i ../zstd-1.5.2-upstream_fixes-1.patch
make prefix=/usr
rm -v /usr/lib/libzstd.a

cd /sources
rm -rf file-5.42
tar xf file-5.42.tar.gz
cd file-5.42

./configure --prefix=/usr
make
make install

cd /sources
rm -rf readline-8.1.2
tar xf readline-8.1.2.tar.gz
cd readline-8.1.2

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr \
 --disable-static \
 --with-curses \
 --docdir=/usr/share/doc/readline-8.1.2
make SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1.2

cd /sources
rm -rf m4-1.4.19
tar xf m4-1.4.19.tar.xz
cd m4-1.4.19

./configure --prefix=/usr
make
make install

cd /sources
rm -rf bc-6.0.1
tar xf bc-6.0.1.tar.xz
cd bc-6.0.1

CC=gcc ./configure --prefix=/usr -G -O3 -r
make
make install

cd /sources
rm -rf flex-2.6.4
tar xf flex-2.6.4.tar.gz
cd flex-2.6.4

./configure --prefix=/usr \
 --docdir=/usr/share/doc/flex-2.6.4 \
 --disable-static
make
make install
ln -sv flex /usr/bin/lex

cd /sources
rm -rf tcl8.6.12-src
tar xf tcl8.6.12-src.tar.gz
cd tcl8.6.12-src

tar -xf ../tcl8.6.12-html.tar.gz --strip-components=1
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr \
 --mandir=/usr/share/man
make
sed -e "s|$SRCDIR/unix|/usr/lib|" \
 -e "s|$SRCDIR|/usr/include|" \
 -i tclConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.3|/usr/lib/tdbc1.1.3|" \
 -e "s|$SRCDIR/pkgs/tdbc1.1.3/generic|/usr/include|" \
 -e "s|$SRCDIR/pkgs/tdbc1.1.3/library|/usr/lib/tcl8.6|" \
 -e "s|$SRCDIR/pkgs/tdbc1.1.3|/usr/include|" \
 -i pkgs/tdbc1.1.3/tdbcConfig.sh
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.2|/usr/lib/itcl4.2.2|" \
 -e "s|$SRCDIR/pkgs/itcl4.2.2/generic|/usr/include|" \
 -e "s|$SRCDIR/pkgs/itcl4.2.2|/usr/include|" \
 -i pkgs/itcl4.2.2/itclConfig.sh
unset SRCDIR

make install
chmod -v u+w /usr/lib/libtcl8.6.so

make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
mkdir -v -p /usr/share/doc/tcl-8.6.12
cp -v -r ../html/* /usr/share/doc/tcl-8.6.12

cd /sources
rm -rf expect5.45.4
tar xf expect5.45.4.tar.gz
cd expect5.45.4

./configure --prefix=/usr \
 --with-tcl=/usr/lib \
 --enable-shared \
 --mandir=/usr/share/man \
 --with-tclinclude=/usr/include
make
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

cd /sources
rm -rf dejagnu-1.6.3
tar xf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

mkdir -v build
cd build

../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext -o doc/dejagnu.txt ../doc/dejagnu.texi

make install
install -v -dm755 /usr/share/doc/dejagnu-1.6.3
install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

cat <<"EOF"
expect -c "spawn ls"
EOF

read -p "Press enter to continue"

cd /sources
rm -rf binutils-2.39
tar xf binutils-2.39.tar.xz
cd binutils-2.39

mkdir -v build
cd build

../configure --prefix=/usr \
 --sysconfdir=/etc \
 --enable-gold \
 --enable-ld=default \
 --enable-plugins \
 --enable-shared \
 --disable-werror \
 --enable-64-bit-bfd \
 --with-system-zlib
make tooldir=/usr

cat <<"EOF"
cd /sources/binutils-2.39/build
make -k check

make tooldir=/usr install

rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
EOF


