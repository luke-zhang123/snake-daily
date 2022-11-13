- 100G自动分区，会是/ 50G  /home 50G
  
- 关闭防火墙

systemctl stop firewalld

systemctl disable firewalld

- 查看路由

ip route

ip route show dev ens33

ip route show 0.0.0.0/0 dev ens33

- 安装gui

yum groupinstall "GNOME Desktop" "Graphical Administration Tools"
systemctl set-default graphical
systemctl start graphical

https://packages.microsoft.com/yumrepos/edge/
https://packages.microsoft.com/yumrepos/vscode/

wget https://packages.microsoft.com/yumrepos/edge/microsoft-edge-stable-107.0.1418.42-1.x86_64.rpm
wget https://packages.microsoft.com/yumrepos/vscode/code-1.73.1-1667967421.el7.x86_64.rpm

tcpdump -ni ens33 dst port 22 -w ssh.dat
