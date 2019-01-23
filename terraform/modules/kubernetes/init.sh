swapoff -a && sysctl -w vm.swappiness=0
sed -i 's/^.*swap.*$//' /etc/fstab
modprobe ip_vs
modprobe ip_vs_sh
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe nf_conntrack_ipv4
