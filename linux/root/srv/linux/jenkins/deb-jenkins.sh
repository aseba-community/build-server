#!/bin/sh
set -eu

RELEASE=$1
ARCH=$2

rm -f *.build *.changes *.deb *.dsc *.tar.gz

MACHINE="/var/lib/machines/$JOB_NAME"

if sudo [ ! -d "$MACHINE" ]
then
	# debootstrap doesn't know the latest ubuntu releases
	if [ ! -f "/usr/share/debootstrap/scripts/$RELEASE" ]
	then sudo ln -s gutsy "/usr/share/debootstrap/scripts/$RELEASE"
	fi

	sudo debootstrap "--arch=$ARCH" --include=equivs,git-buildpackage,sudo --components=main,universe --variant=buildd "$RELEASE" "$MACHINE" http://archive.ubuntu.com/ubuntu/

	sudo mkdir "$MACHINE/srv/linux"
	sudo mkdir "$MACHINE/var/lib/jenkins"

	sudo chroot "$MACHINE" groupadd --non-unique --gid `id --group jenkins` jenkins
	sudo chroot "$MACHINE" useradd --non-unique --home /var/lib/jenkins --uid `id --user jenkins` --gid `id --group jenkins` jenkins
	sudo cp /etc/sudoers.d/jenkins "$MACHINE/etc/sudoers.d/jenkins"

	sudo chroot "$MACHINE" apt-get clean
	echo deb file:/var/lib/jenkins/userContent/debian "$RELEASE" origin/master | sudo tee "$MACHINE/etc/apt/sources.list.d/jenkins.list"
fi

if !(mount | grep --quiet --fixed-strings "$MACHINE")
then
	sudo mount --bind /srv/linux "$MACHINE/srv/linux"
	sudo mount --bind /var/lib/jenkins "$MACHINE/var/lib/jenkins"
fi

sudo chroot "$MACHINE" /srv/linux/jenkins/deb-container.sh "$WORKSPACE" "$BUILD_ID"

DEBIAN_DIR="$JENKINS_HOME/userContent/debian"
BINARY_DIR="dists/$RELEASE/$GIT_BRANCH/binary-$ARCH"
cp *.* "$DEBIAN_DIR/$BINARY_DIR"
cd "$DEBIAN_DIR"
dpkg-scanpackages "$BINARY_DIR" > "$BINARY_DIR/Packages"
