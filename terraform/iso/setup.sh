date > /etc/vagrant_box_build_time

mount -o loop /home/vagrant/VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f /home/vagrant/VBoxGuestAdditions.iso

# ref https://github.com/box-cutter/centos-vm/
# rm -f /var/lib/NetworkManager/*
rm -rf /tmp/*
yum -y clean all

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

sync
