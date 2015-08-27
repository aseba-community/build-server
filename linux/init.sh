#!/bin/sh
set -eu
cd `dirname "$0"`

mkdir --parents ~/.ssh
cp authorized_keys ~/.ssh/authorized_keys

curl --output /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum --assumeyes install epel-release
yum --assumeyes install java jenkins git debootstrap dpkg-dev
yum --assumeyes upgrade

cp jenkins/sudoers /etc/sudoers.d/jenkins
cp jenkins/init.groovy /var/lib/jenkins/init.groovy
systemctl enable jenkins.service

# ubuntu
for release in precise trusty vivid
do
	for arch in amd64 i386
	do
		machine="$release-$arch"
		container="/var/lib/container/$machine"

		debootstrap "--arch=$arch" --include=equivs,git-buildpackage --components=main,universe --variant=buildd "$release" "$container" http://archive.ubuntu.com/ubuntu/
		# precise doesn't have this file
		touch "$container/etc/os-release"
		systemd-nspawn "--directory=$container" apt-get clean

		repository="/var/lib/jenkins/userContent/debian"
		branch="origin/master"
		echo deb "file:$repository" "$release" "$branch" > "$container/etc/apt/sources.list.d/jenkins.list"
	done
done

echo aseba-build-linux > /etc/hostname
timedatectl set-timezone Europe/Zurich

systemctl disable init.service
systemctl reboot
