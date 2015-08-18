#!/bin/sh
cd `dirname "$0"`

MACHINE=builder-linux
IMAGE=CentOS-7-x86_64-GenericCloud-1503

VBoxManage createvm --name "$MACHINE" --ostype RedHat_64 --register --basefolder "$PWD"
VBoxManage modifyvm "$MACHINE"\
 --memory 4096\
 --vram 16\
 --nictype1 virtio\
 --natpf1 sshd,tcp,127.0.0.1,2222,,22\
 --natpf1 jenkins,tcp,,8080,,8080\
 --boot1 disk\
 --boot2 none\
 --boot3 none
VBoxManage storagectl "$MACHINE" --name SATA --add sata

if [ ! -f $IMAGE.qcow2.xz ]
then curl --remote-name http://cloud.centos.org/centos/7/images/$IMAGE.qcow2.xz
fi

xz --decompress --keep "$IMAGE.qcow2.xz"
qemu-img resize "$IMAGE.qcow2" 16G
LIBGUESTFS_BACKEND=direct guestfish --add "$IMAGE.qcow2" --inspector << EOF
copy-in srv /srv
mv /srv/srv "/srv/$MACHINE"
cp "/srv/$MACHINE/init.service" /etc/systemd/system/
ln-s "/srv/$MACHINE/init.service" /etc/systemd/system/multi-user.target.wants/
EOF
qemu-img convert -O vdi "$IMAGE.qcow2" "$MACHINE/$MACHINE.vdi"
rm --force "$IMAGE.qcow2"

VBoxManage storageattach "$MACHINE" --storagectl SATA --port 0 --type hdd --medium "$MACHINE/$MACHINE.vdi"
