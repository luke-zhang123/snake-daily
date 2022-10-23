#!/bin/bash
# chapter 7 after chroot

run_user=$(id -u -n)
if [ "$run_user" != "root" ];then
  echo "run as root user, current user $run_user"
  exit 1
fi

if [ "$(stat -c %d:%i /)" == "$(stat -c %d:%i /proc/1/root/.)" ]; then
  echo "not in chroot"
  exit 1
fi

cd /sources
rm -rf gettext-0.21
tar xf gettext-0.21.tar.xz
cd gettext-0.21

./configure --disable-shared
make

cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

cd /sources
rm -rf bison-3.8.2
tar xf bison-3.8.2.tar.xz
cd bison-3.8.2

./configure --prefix=/usr \
 --docdir=/usr/share/doc/bison-3.8.2
make
make install

cd /sources
rm -rf perl-5.36.0
tar xf perl-5.36.0.tar.xz
cd perl-5.36.0

sh Configure -des \
 -Dprefix=/usr \
 -Dvendorprefix=/usr \
 -Dprivlib=/usr/lib/perl5/5.36/core_perl \
 -Darchlib=/usr/lib/perl5/5.36/core_perl \
 -Dsitelib=/usr/lib/perl5/5.36/site_perl \
 -Dsitearch=/usr/lib/perl5/5.36/site_perl \
 -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl \
 -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl
make
make install

cd /sources
rm -rf Python-3.10.6
tar xf Python-3.10.6.tar.xz
cd Python-3.10.6

./configure --prefix=/usr \
 --enable-shared \
 --without-ensurepip
make
make install

cd /sources
rm -rf texinfo-6.8
tar xf texinfo-6.8.tar.xz
cd texinfo-6.8

./configure --prefix=/usr
make
make install

cd /sources
rm -rf util-linux-2.38.1
tar xf util-linux-2.38.1.tar.xz
cd util-linux-2.38.1

mkdir -pv /var/lib/hwclock

./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
 --libdir=/usr/lib \
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
 runstatedir=/run
make
make install

cat <<"EOF"
cleaning:
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
EOF
