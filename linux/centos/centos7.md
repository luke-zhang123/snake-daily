- 100G自动分区，会是/ 50G  /home 50G
  
- 关闭防火墙

systemctl stop firewalld

systemctl disable firewalld

- 查看路由

ip route

ip route show dev ens33

ip route show 0.0.0.0/0 dev ens33

