install
url --url https://mirrors.163.com/centos/7/os/x86_64

lang en_US.UTF-8
keyboard us
network --device eth0 --bootproto dhcp
selinux --disabled
firewall --disabled
timezone --utc Asia/Shanghai
# The biosdevname and ifnames options ensure we get "eth0" as our interface
# even in environments like virtualbox that emulate a real NW card
bootloader --timeout=1 --append="no_timer_check console=tty0 console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop"
zerombr
services --disabled="kdump" --enabled="network,sshd"

text
skipx

clearpart --drives=sda --all --initlabel
part / --fstype xfs --size=10 --grow --ondrive=sda
firstboot --disabled

rootpw vagrant
auth --enableshadow --passalgo=sha512 --kickstart
user --name=vagrant --password=vagrant --groups=vagrant,wheel

reboot

%packages --excludedocs --instLangs=en

bzip2
curl
gcc
ipset
ipvsadm
kernel-devel
make
net-tools
nfs-utils
openssh-clients
openssh-server
perl
sed
selinux-policy-devel
sudo
yum-utils

# useless
-*firmware
-audit*
# Don't build rescue initramfs
-dracut-config-rescue
-efibootmgr
-firwalld
-fontconfig
-fprintd-pam
-freetype
# Disable kdump
-kexec-tools
-intltool
-libX*
# Microcode updates cannot work in a VM
-microcode_ctl
# Vagrant boxes aren't normally visible, no need for Plymouth
-plymouth

%end

%post

# disable selinux
# setenforce 0
# sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# sudo
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Fix for https://github.com/CentOS/sig-cloud-instance-build/issues/38
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="yes"
EOF

# sshd: disable password authentication and DNS checks
#:%substitute/^\(PasswordAuthentication\) yes$/\1 no/
ex -s /etc/ssh/sshd_config <<EOF
:%substitute/^#\(UseDNS\) yes$/&\r\1 no/
:update
:quit
EOF

cat >>/etc/sysconfig/sshd <<EOF
# Decrease connection time by preventing reverse DNS lookups
# (see https://lists.centos.org/pipermail/centos-devel/2016-July/014981.html
#  and man sshd for more information)
OPTIONS="-u0"
EOF

# Default insecure vagrant key
mkdir -m 0700 -p /home/vagrant/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Fix for issue #76, regular users can gain admin privileges via su
ex -s /etc/pam.d/su <<'EOF'
# allow vagrant to use su, but prevent others from becoming root or vagrant
/^account\s\+sufficient\s\+pam_succeed_if.so uid = 0 use_uid quiet$/
:append
account     [success=1 default=ignore] \\
                pam_succeed_if.so user = vagrant use_uid quiet
account     required    pam_succeed_if.so user notin root:vagrant
.
:update
:quit
EOF

# systemd should generate a new machine id during the first boot, to
# avoid having multiple Vagrant instances with the same id in the local
# network. /etc/machine-id should be empty, but it must exist to prevent
# boot errors (e.g.  systemd-journald failing to start).
:>/etc/machine-id

echo 'vag' > /etc/yum/vars/infra


# Blacklist the floppy module to avoid probing timeouts
echo blacklist floppy > /etc/modprobe.d/nofloppy.conf
chcon -u system_u -r object_r -t modules_conf_t /etc/modprobe.d/nofloppy.conf

# Customize the initramfs
pushd /etc/dracut.conf.d
# There's no floppy controller, but probing for it generates timeouts
echo 'omit_drivers+=" floppy "' > nofloppy.conf
popd
# Fix the SELinux context of the new files
restorecon -f - <<EOF
/etc/sudoers.d/vagrant
/etc/dracut.conf.d/nofloppy.conf
EOF

# Rerun dracut for the installed kernel (not the running kernel):
KERNEL_VERSION=$(rpm -q kernel --qf '%{version}-%{release}.%{arch}\n')
dracut -f /boot/initramfs-${KERNEL_VERSION}.img ${KERNEL_VERSION}

# Seal for deployment
rm -rf /etc/ssh/ssh_host_*
hostnamectl set-hostname localhost.localdomain
rm -rf /etc/udev/rules.d/70-*

%end
