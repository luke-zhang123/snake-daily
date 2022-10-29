- [内核编译选配,scsi硬盘驱动（VMware篇）](https://www.cnblogs.com/sysk/p/4987698.html)

- [Manually add menu entry to GRUB2 menu](https://computingforgeeks.com/manually-add-menu-entry-to-grub2-menu-on-arch-linux/)

grub2-mkconfig  会自动os-prober发现其他kernel，但是配置不一定对，尤其没有initramfs启动的

grub2-mkconfig -o /boot/grub2/grub.cfg 加-o写入指定文件，不加，打印到屏幕

/etc/grub.d/40_custom  加入自己的menu
