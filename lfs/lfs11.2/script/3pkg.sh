#!/bin/bash
if [ -z "$LFS" ];then
  echo -e "LFS var is empty\nsource .bashrc\necho \$LFS"
  exit 1
fi
if [ ! -f lfs-packages-11.2.tar ];then
  echo "lfs-packages-11.2.tar not found at $PWD"
  exit 1
fi
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
tar xvf lfs-packages-11.2.tar -C $LFS/sources
mv $LFS/sources/11.2-rc1/* $LFS/sources/
ls $LFS/sources/
pushd $LFS/sources
 md5sum -c md5sums
popd
ls $LFS/sources
echo "ls \$LFS/sources"