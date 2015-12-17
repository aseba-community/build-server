#!/bin/sh
set -eu
cd `dirname "$0"`

mkdir --parents ~/.ssh
cp authorized_keys ~/.ssh/authorized_keys

curl --output /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum --assumeyes install epel-release
yum --assumeyes install java jenkins git debootstrap dpkg-dev lftp yum-cron dkms
yum --assumeyes upgrade

curl --output /tmp/VBoxGuestAdditions.iso http://download.virtualbox.org/virtualbox/5.0.10/VBoxGuestAdditions_5.0.10.iso
mkdir /tmp/VBoxGuestAdditions
mount --options loop /tmp/VBoxGuestAdditions.iso /tmp/VBoxGuestAdditions
/tmp/VBoxGuestAdditions/VBoxLinuxAdditions.run

sed --in-place "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf
systemctl enable yum-cron

cp jenkins/sudoers /etc/sudoers.d/jenkins
cp --recursive --no-target-directory jenkins/home /var/lib/jenkins
chown --recursive jenkins:jenkins /var/lib/jenkins
systemctl enable jenkins.service

jenkins_uid=`id --user jenkins`
jenkins_gid=`id --group jenkins`

# ubuntu
for release in precise trusty vivid wily
do
	for arch in amd64 i386
	do
		machine="$release-$arch"
		container="/var/lib/machines/$machine"

		if [ ! -f "/usr/share/debootstrap/scripts/$release" ]
		# debootstrap doesn't know the latest ubuntu releases
		then ln -s gutsy "/usr/share/debootstrap/scripts/$release"
		fi

		debootstrap "--arch=$arch" --include=equivs,git-buildpackage,sudo --components=main,universe --variant=buildd "$release" "$container" http://archive.ubuntu.com/ubuntu/

		if [ ! -f "$container/etc/os-release" ]
		# precise doesn't have this file
		then touch "$container/etc/os-release"
		fi

		# systemd-nspawn cannot run bind-mounted programs
		cp --recursive /srv/linux "$container/srv/linux"

		systemd-nspawn "--machine=$machine" --bind=/var/lib/jenkins /srv/linux/deb-init.sh "$release" "$jenkins_uid" "$jenkins_gid"
	done
done

echo aseba-build-linux > /etc/hostname
timedatectl set-timezone Europe/Zurich

systemctl disable init.service
systemctl reboot
