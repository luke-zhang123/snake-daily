#!/bin/bash
# chapter 8

set -e

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

pwd
cat <<"EOF"
run follow cmd:
make check
EOF
read -p "Press enter to continue"

touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

make install

sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

make localedata/install-locales

localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2022c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica \
 asia australasia backward; do
 zic -L /dev/null -d $ZONEINFO ${tz}
 zic -L /dev/null -d $ZONEINFO/posix ${tz}
 zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

pwd
echo -e "run cmd: tzselect"
read -p "Press enter to continue"

ln -sfv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

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
make prefix=/usr install
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
rm -rf tcl8.6.12
tar xf tcl8.6.12-src.tar.gz
cd tcl8.6.12

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

cd /sources
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

pwd
cat <<"EOF"
run test before binutils:
expect -c "spawn ls"

  output:
spawn ls
  output failed:
The system has no more ptys.
Ask your system administrator to create more.
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

pwd
echo -e "run test cmd:\nmake -k check"
read -p "Press enter to continue"

make tooldir=/usr install

rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a

cd /sources
rm -rf gmp-6.2.1
tar xf gmp-6.2.1.tar.xz
cd gmp-6.2.1

./configure --prefix=/usr \
 --enable-cxx \
 --disable-static \
 --docdir=/usr/share/doc/gmp-6.2.1
make
make html

pwd
cat <<"EOF"
run test cmd:
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

all 197 tests passed
EOF
read -p "Press enter to continue"

make install
make install-html

cd /sources
rm -rf mpfr-4.1.0
tar xf mpfr-4.1.0.tar.xz
cd mpfr-4.1.0

./configure --prefix=/usr \
 --disable-static \
 --enable-thread-safe \
 --docdir=/usr/share/doc/mpfr-4.1.0
make
make html

pwd
cat <<"EOF"
run test cmd:
make check
EOF
read -p "Press enter to continue"

make install
make install-html

cd /sources
rm -rf mpc-1.2.1
tar xf mpc-1.2.1.tar.gz
cd mpc-1.2.1

./configure --prefix=/usr \
 --disable-static \
 --docdir=/usr/share/doc/mpc-1.2.1
make
make html
make install
make install-html

cd /sources
rm -rf attr-2.5.1
tar xf attr-2.5.1.tar.gz
cd attr-2.5.1

./configure --prefix=/usr \
 --disable-static \
 --sysconfdir=/etc \
 --docdir=/usr/share/doc/attr-2.5.1
make
make install

cd /sources
rm -rf acl-2.3.1
tar xf acl-2.3.1.tar.xz
cd acl-2.3.1

./configure --prefix=/usr \
 --disable-static \
 --docdir=/usr/share/doc/acl-2.3.1
make
make install

cd /sources
rm -rf libcap-2.65
tar xf libcap-2.65.tar.xz
cd libcap-2.65

sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make prefix=/usr lib=lib install

cd /sources
rm -rf shadow-4.12.2
tar xf shadow-4.12.2.tar.xz
cd shadow-4.12.2

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
 -e 's:/var/spool/mail:/var/mail:' \
 -e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
 -i etc/login.defs

touch /usr/bin/passwd
./configure --sysconfdir=/etc \
 --disable-static \
 --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man

pwconv
grpconv

mkdir -p /etc/default
useradd -D --gid 999

echo 'root:111111' |chpasswd

cd /sources
rm -rf gcc-12.2.0
tar xf gcc-12.2.0.tar.xz
cd gcc-12.2.0

case $(uname -m) in
 x86_64)
 sed -e '/m64=/s/lib64/lib/' \
 -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd build

../configure --prefix=/usr \
 LD=ld \
 --enable-languages=c,c++ \
 --disable-multilib \
 --disable-bootstrap \
 --with-system-zlib
make

pwd
cat <<"EOF"
run test cmd:
ulimit -s 32768

chown -Rv tester .
su tester -c "PATH=$PATH make -k check"

../contrib/test_summary
EOF
read -p "Press enter to continue"

make install

chown -v -R root:root \
 /usr/lib/gcc/$(gcc -dumpmachine)/12.2.0/include{,-fixed}

ln -svr /usr/bin/cpp /usr/lib

ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/12.2.0/liblto_plugin.so \
 /usr/lib/bfd-plugins/

pwd
cat <<"EOF"
run test cmd:
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
  output:
[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
  output:
/usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib/crt1.o succeeded
/usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib/crti.o succeeded
/usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib/crtn.o succeeded

grep -B4 '^ /usr/include' dummy.log
  output:
#include <...> search starts here:
 /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/include
 /usr/local/include
 /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/include-fixed
 /usr/include

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
  output:
SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")
SEARCH_DIR("/usr/local/lib64")
SEARCH_DIR("/lib64")
SEARCH_DIR("/usr/lib64")
SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")
SEARCH_DIR("/usr/local/lib")
SEARCH_DIR("/lib")
SEARCH_DIR("/usr/lib");

grep "/lib.*/libc.so.6 " dummy.log
  output:
attempt to open /usr/lib/libc.so.6 succeeded

grep found dummy.log
  output:
found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2

rm -v dummy.c a.out dummy.log
EOF
read -p "Press enter to continue"

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd /sources
rm -rf pkg-config-0.29.2
tar xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2

./configure --prefix=/usr \
 --with-internal-glib \
 --disable-host-tool \
 --docdir=/usr/share/doc/pkg-config-0.29.2
make
make install

cd /sources
rm -rf ncurses-6.3
tar xf ncurses-6.3.tar.gz
cd ncurses-6.3

./configure --prefix=/usr \
 --mandir=/usr/share/man \
 --with-shared \
 --without-debug \
 --without-normal \
 --with-cxx-shared \
 --enable-pc-files \
 --enable-widec \
 --with-pkg-config-libdir=/usr/lib/pkgconfig
make
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.3 /usr/lib
rm -v dest/usr/lib/libncursesw.so.6.3
cp -av dest/* /

for lib in ncurses form panel menu ; do
 rm -vf /usr/lib/lib${lib}.so
 echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
 ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
done

rm -vf /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so /usr/lib/libcurses.so

mkdir -pv /usr/share/doc/ncurses-6.3
cp -v -R doc/* /usr/share/doc/ncurses-6.3

cd /sources
rm -rf sed-4.8
tar xf sed-4.8.tar.xz
cd sed-4.8

./configure --prefix=/usr
make
make html
make install
install -d -m755 /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8

cd /sources
rm -rf psmisc-23.5
tar xf psmisc-23.5.tar.xz
cd psmisc-23.5

./configure --prefix=/usr
make
make install

cd /sources
rm -rf gettext-0.21
tar xf gettext-0.21.tar.xz
cd gettext-0.21

./configure --prefix=/usr \
 --disable-static \
 --docdir=/usr/share/doc/gettext-0.21
make
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd /sources
rm -rf bison-3.8.2
tar xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make
make install

cd /sources
rm -rf grep-3.7
tar xf grep-3.7.tar.xz
cd grep-3.7

./configure --prefix=/usr
make
make install

cd /sources
rm -rf bash-5.1.16
tar xf bash-5.1.16.tar.gz
cd bash-5.1.16

./configure --prefix=/usr \
 --docdir=/usr/share/doc/bash-5.1.16 \
 --without-bash-malloc \
 --with-installed-readline
make
make install

# exec /usr/bin/bash --login

cd /sources
rm -rf libtool-2.4.7
tar xf libtool-2.4.7.tar.xz
cd libtool-2.4.7

./configure --prefix=/usr
make
make install

rm -fv /usr/lib/libltdl.a

cd /sources
rm -rf gdbm-1.23
tar xf gdbm-1.23.tar.gz
cd gdbm-1.23

./configure --prefix=/usr \
 --disable-static \
 --enable-libgdbm-compat
make
make install

cd /sources
rm -rf gperf-3.1
tar xf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
make install

cd /sources
rm -rf expat-2.4.8
tar xf expat-2.4.8.tar.xz
cd expat-2.4.8

./configure --prefix=/usr \
 --disable-static \
 --docdir=/usr/share/doc/expat-2.4.8
make
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.4.8

cd /sources
rm -rf inetutils-2.3
tar xf inetutils-2.3.tar.xz
cd inetutils-2.3

./configure --prefix=/usr \
 --bindir=/usr/bin \
 --localstatedir=/var \
 --disable-logger \
 --disable-whois \
 --disable-rcp \
 --disable-rexec \
 --disable-rlogin \
 --disable-rsh \
 --disable-servers
make
make install
mv -v /usr/{,s}bin/ifconfig

cd /sources
rm -rf less-590
tar xf less-590.tar.gz
cd less-590

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd /sources
rm -rf perl-5.36.0
tar xf perl-5.36.0.tar.xz
cd perl-5.36.0

export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des \
 -Dprefix=/usr \
 -Dvendorprefix=/usr \
 -Dprivlib=/usr/lib/perl5/5.36/core_perl \
 -Darchlib=/usr/lib/perl5/5.36/core_perl \
 -Dsitelib=/usr/lib/perl5/5.36/site_perl \
 -Dsitearch=/usr/lib/perl5/5.36/site_perl \
 -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl \
 -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl \
 -Dman1dir=/usr/share/man/man1 \
 -Dman3dir=/usr/share/man/man3 \
 -Dpager="/usr/bin/less -isR" \
 -Duseshrplib \
 -Dusethreads
make
make install
unset BUILD_ZLIB BUILD_BZIP2

cd /sources
rm -rf XML-Parser-2.46
tar xf XML-Parser-2.46.tar.gz
cd XML-Parser-2.46

perl Makefile.PL
make
make install

cd /sources
rm -rf intltool-0.51.0
tar xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd /sources
rm -rf autoconf-2.71
tar xf autoconf-2.71.tar.xz
cd autoconf-2.71

./configure --prefix=/usr
make
make install

cd /sources
rm -rf automake-1.16.5
tar xf automake-1.16.5.tar.xz
cd automake-1.16.5

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
make
make install

cd /sources
rm -rf openssl-3.0.5
tar xf openssl-3.0.5.tar.gz
cd openssl-3.0.5

./config --prefix=/usr \
 --openssldir=/etc/ssl \
 --libdir=lib \
 shared \
 zlib-dynamic
make
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.0.5
cp -vfr doc/* /usr/share/doc/openssl-3.0.5

cd /sources
rm -rf kmod-30
tar xf kmod-30.tar.xz
cd kmod-30

./configure --prefix=/usr \
 --sysconfdir=/etc \
 --with-openssl \
 --with-xz \
 --with-zstd \
 --with-zlib
make
make install

for target in depmod insmod modinfo modprobe rmmod; do
 ln -sfv ../bin/kmod /usr/sbin/$target
done
ln -sfv kmod /usr/bin/lsmod

cd /sources
rm -rf elfutils-0.187
tar xf elfutils-0.187.tar.bz2
cd elfutils-0.187

./configure --prefix=/usr \
 --disable-debuginfod \
 --enable-libdebuginfod=dummy
make
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd /sources
rm -rf libffi-3.4.2
tar xf libffi-3.4.2.tar.gz
cd libffi-3.4.2

./configure --prefix=/usr \
 --disable-static \
 --with-gcc-arch=native \
 --disable-exec-static-tramp
make
make install

cd /sources
rm -rf Python-3.10.6
tar xf Python-3.10.6.tar.xz
cd Python-3.10.6

./configure --prefix=/usr \
 --enable-shared \
 --with-system-expat \
 --with-system-ffi \
 --enable-optimizations
make
make install

cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.10.6/html
tar --strip-components=1 \
 --no-same-owner \
 --no-same-permissions \
 -C /usr/share/doc/python-3.10.6/html \
 -xvf ../python-3.10.6-docs-html.tar.bz2

cd /sources
rm -rf wheel-0.37.1
tar xf wheel-0.37.1.tar.gz
cd wheel-0.37.1

pip3 install --no-index $PWD

cd /sources
rm -rf ninja-1.11.0
tar xf ninja-1.11.0.tar.gz
cd ninja-1.11.0

export NINJAJOBS=4

sed -i '/int Guess/a \
 int j = 0;\
 char* jobs = getenv( "NINJAJOBS" );\
 if ( jobs != NULL ) j = atoi( jobs );\
 if ( j > 0 ) return j;\
' src/ninja.cc

python3 configure.py --bootstrap
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja

cd /sources
rm -rf meson-0.63.1
tar xf meson-0.63.1.tar.gz
cd meson-0.63.1

pip3 wheel -w dist --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /sources
rm -rf coreutils-9.1
tar xf coreutils-9.1.tar.xz
cd coreutils-9.1

patch -Np1 -i ../coreutils-9.1-i18n-1.patch

autoreconf -fiv
FORCE_UNSAFE_CONFIGURE=1 ./configure \
 --prefix=/usr \
 --enable-no-install-program=kill,uptime
make
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd /sources
rm -rf check-0.15.2
tar xf check-0.15.2.tar.gz
cd check-0.15.2

./configure --prefix=/usr --disable-static
make
make docdir=/usr/share/doc/check-0.15.2 install

cd /sources
rm -rf diffutils-3.8
tar xf diffutils-3.8.tar.xz
cd diffutils-3.8

./configure --prefix=/usr
make
make install

cd /sources
rm -rf gawk-5.1.1
tar xf gawk-5.1.1.tar.xz
cd gawk-5.1.1

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
make install
mkdir -pv /usr/share/doc/gawk-5.1.1
cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.1

cd /sources
rm -rf findutils-4.9.0
tar xf findutils-4.9.0.tar.xz
cd findutils-4.9.0

case $(uname -m) in
 i?86) TIME_T_32_BIT_OK=yes ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
 x86_64) ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
esac

make
make install

cd /sources
rm -rf groff-1.22.4
tar xf groff-1.22.4.tar.gz
cd groff-1.22.4

PAGE=A4 ./configure --prefix=/usr
unset MAKEFLAGS
make -j1
export MAKEFLAGS="-j$(nproc)"
make install

cd /sources
rm -rf grub-2.06
tar xf grub-2.06.tar.xz
cd grub-2.06

./configure --prefix=/usr \
 --sysconfdir=/etc \
 --disable-efiemu \
 --disable-werror

make
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd /sources
rm -rf gzip-1.12
tar xf gzip-1.12.tar.xz
cd gzip-1.12

./configure --prefix=/usr
make
make install

cd /sources
rm -rf iproute2-5.19.0
tar xf iproute2-5.19.0.tar.xz
cd iproute2-5.19.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install

mkdir -pv /usr/share/doc/iproute2-5.19.0
cp -v COPYING README* /usr/share/doc/iproute2-5.19.0

cd /sources
rm -rf kbd-2.5.1
tar xf kbd-2.5.1.tar.xz
cd kbd-2.5.1

patch -Np1 -i ../kbd-2.5.1-backspace-1.patch

sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

./configure --prefix=/usr --disable-vlock
make
make install

mkdir -pv /usr/share/doc/kbd-2.5.1
cp -R -v docs/doc/* /usr/share/doc/kbd-2.5.1

cd /sources
rm -rf libpipeline-1.5.6
tar xf libpipeline-1.5.6.tar.gz
cd libpipeline-1.5.6

./configure --prefix=/usr
make
make install

cd /sources
rm -rf make-4.3
tar xf make-4.3.tar.gz
cd make-4.3

./configure --prefix=/usr
make
make install

cd /sources
rm -rf patch-2.7.6
tar xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr
make
make install

cd /sources
rm -rf tar-1.34
tar xf tar-1.34.tar.xz
cd tar-1.34

FORCE_UNSAFE_CONFIGURE=1 \
./configure --prefix=/usr
make
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34

cd /sources
rm -rf texinfo-6.8
tar xf texinfo-6.8.tar.xz
cd texinfo-6.8

./configure --prefix=/usr
make
make install

make TEXMF=/usr/share/texmf install-tex

cd /sources
rm -rf vim-9.0.0228
tar xf vim-9.0.0228.tar.gz
cd vim-9.0.0228

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr
make
make install

ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
 ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim90/doc /usr/share/doc/vim-9.0.0228

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
 set background=dark
endif
" End /etc/vimrc
EOF

cd /sources
rm -rf eudev-3.2.11
tar xf eudev-3.2.11.tar.gz
cd eudev-3.2.11

./configure --prefix=/usr \
 --bindir=/usr/sbin \
 --sysconfdir=/etc \
 --enable-manpages \
 --disable-static
make
mkdir -pv /usr/lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
make install
tar -xvf ../udev-lfs-20171102.tar.xz
make -f udev-lfs-20171102/Makefile.lfs install

udevadm hwdb --update

cd /sources
rm -rf man-db-2.10.2
tar xf man-db-2.10.2.tar.xz
cd man-db-2.10.2

./configure --prefix=/usr \
 --docdir=/usr/share/doc/man-db-2.10.2 \
 --sysconfdir=/etc \
 --disable-setuid \
 --enable-cache-owner=bin \
 --with-browser=/usr/bin/lynx \
 --with-vgrind=/usr/bin/vgrind \
 --with-grap=/usr/bin/grap \
 --with-systemdtmpfilesdir= \
 --with-systemdsystemunitdir=
make
make install

cd /sources
rm -rf procps-ng-4.0.0
tar xf procps-ng-4.0.0.tar.xz
cd procps-ng-4.0.0

./configure --prefix=/usr \
 --docdir=/usr/share/doc/procps-ng-4.0.0 \
 --disable-static \
 --disable-kill
make
make install

cd /sources
rm -rf util-linux-2.38.1
tar xf util-linux-2.38.1.tar.xz
cd util-linux-2.38.1

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
 --bindir=/usr/bin \
 --libdir=/usr/lib \
 --sbindir=/usr/sbin \
 --docdir=/usr/share/doc/util-linux-2.38.1 \
 --disable-chfn-chsh \
 --disable-login \
 --disable-nologin \
 --disable-su \
 --disable-setpriv \
 --disable-runuser \
 --disable-pylibmount \
 --disable-static \
 --without-python \
 --without-systemd \
 --without-systemdsystemunitdir
make
make install

cd /sources
rm -rf e2fsprogs-1.46.5
tar xf e2fsprogs-1.46.5.tar.gz
cd e2fsprogs-1.46.5

mkdir -v build
cd build

../configure --prefix=/usr \
 --sysconfdir=/etc \
 --enable-elf-shlibs \
 --disable-libblkid \
 --disable-libuuid \
 --disable-uuidd \
 --disable-fsck
make
make install

rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd /sources
rm -rf sysklogd-1.5.1
tar xf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1

sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c

make
make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
# End /etc/syslog.conf
EOF

cd /sources
rm -rf sysvinit-3.04
tar xf sysvinit-3.04.tar.xz
cd sysvinit-3.04

patch -Np1 -i ../sysvinit-3.04-consolidated-1.patch
make
make install

rm -rf /tmp/*
find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
userdel -r tester

cd /sources
rm -rf lfs-bootscripts-20220723
tar xf lfs-bootscripts-20220723.tar.xz
cd lfs-bootscripts-20220723

make install

