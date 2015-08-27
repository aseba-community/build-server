#!/bin/sh
set -eu

RELEASE=$1
ARCH=$2

if [ ! -d machine ]
#TODO: use tar.xz
then sudo cp --recursive "/var/lib/container/$RELEASE-$ARCH" machine
fi

sudo systemd-nspawn\
 --directory=machine\
 "--machine=$BUILD_TAG"\
 --bind=/srv/linux\
 --bind=/var/lib/jenkins\
 /srv/linux/jenkins/deb-build.sh\
 "$WORKSPACE"

TARGET="$JENKINS_HOME/userContent/dists/$RELEASE/$GIT_BRANCH/binary-$ARCH"
mkdir -p "$TARGET"
cp *.* "$TARGET"

cd "$TARGET"
dpkg-scanpackages . > Packages
