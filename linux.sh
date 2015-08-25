#!/bin/sh
cd `dirname "$0"`

MACHINE=linux
IMAGE=CentOS-7-x86_64-GenericCloud-1503

if [ ! -f $IMAGE.qcow2.xz ]
then curl --remote-name http://cloud.centos.org/centos/7/images/$IMAGE.qcow2.xz
fi

xz --decompress --keep "$IMAGE.qcow2.xz"
qemu-img resize "$IMAGE.qcow2" 16G

LIBGUESTFS_BACKEND=direct guestfish --add "$IMAGE.qcow2" --inspector << EOF
copy-in "$MACHINE" /srv/
cp "/srv/$MACHINE/init.service" /etc/systemd/system/
ln-s "/srv/$MACHINE/init.service" /etc/systemd/system/multi-user.target.wants/
EOF

qemu-img convert -O vdi "$IMAGE.qcow2" "osx/$MACHINE.vdi"
rm --force "$IMAGE.qcow2"
