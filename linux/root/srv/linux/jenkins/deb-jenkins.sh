#!/bin/sh
set -eu

RELEASE=$1
ARCH=$2

if [ ! -d "/var/lib/machines/$JOB_NAME" ]
#TODO: use tar.xz
then sudo cp --recursive "/var/lib/machines/$RELEASE-$ARCH" "/var/lib/machines/$JOB_NAME"
fi

sudo systemd-nspawn\
 "--machine=$JOB_NAME"\
 --bind=/srv/linux\
 --bind=/var/lib/jenkins\
 /srv/linux/jenkins/deb-container.sh\
 "$WORKSPACE" "$BUILD_ID"

DEBIAN_DIR="$JENKINS_HOME/userContent/debian"
BINARY_DIR="dists/$RELEASE/$GIT_BRANCH/binary-$ARCH"
cp *.* "$DEBIAN_DIR/$BINARY_DIR"
cd "$DEBIAN_DIR"
dpkg-scanpackages "$BINARY_DIR" > "$BINARY_DIR/Packages"
