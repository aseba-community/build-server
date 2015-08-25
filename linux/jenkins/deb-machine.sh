#!/bin/sh

machine=$1

if [ ! -d machine ]
#TODO: use tar.xz
then sudo cp --recursive "/var/lib/container/$machine" machine
fi

sudo systemd-nspawn\
 --directory=machine\
 "--machine=$BUILD_TAG"\
 --bind=/srv/linux\
 --bind=/var/lib/jenkins\
 /srv/linux/jenkins/deb-build.sh\
 "$WORKSPACE"
