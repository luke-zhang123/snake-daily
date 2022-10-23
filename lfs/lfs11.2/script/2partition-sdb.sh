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