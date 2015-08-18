#!/bin/sh

mkdir --parents ~/.ssh
cp authorized_keys ~/.ssh/authorized_keys

echo mobsya-builder-linux > /etc/hostname
timedatectl set-timezone Europe/Zurich

curl --output /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum --assumeyes install epel-release
yum --assumeyes install java jenkins git debootstrap
yum --assumeyes upgrade

cp jenkins/sudoers /etc/sudoers.d/jenkins
cp jenkins/init.groovy /var/lib/jenkins/init.groovy
systemctl enable jenkins.service

# ubuntu
for release in precise trusty vivid
do
	for arch in amd64 i386
	do
		machine=ubuntu-$release-$arch
		directory=/var/lib/container/$machine
		debootstrap "--arch=$arch" --include=equivs,git-buildpackage --components=main,universe --variant=buildd "$release" "$directory" http://archive.ubuntu.com/ubuntu/
		# precise doesn't have this file
		touch "$directory/etc/os-release"
		systemd-nspawn "--directory=$directory" apt-get clean
	done
done

systemctl disable init.service
systemctl reboot
