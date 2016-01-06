#!/bin/sh
set -eu
cd `dirname "$0"`

timedatectl set-timezone Europe/Zurich

yum --assumeyes install epel-release
yum --assumeyes upgrade

yum --assumeyes install yum-cron
sed --in-place "s/apply_updates = no/apply_updates = yes/" /etc/yum/yum-cron.conf
systemctl enable yum-cron.service

yum --assumeyes install git debootstrap dpkg-dev lftp

curl --output /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum --assumeyes install java jenkins
chmod ug=r,o= /etc/sudoers.d/jenkins
chown --recursive jenkins:jenkins /var/lib/jenkins
systemctl enable jenkins.service

yum --assumeyes install dkms
systemctl enable VBoxGuestAdditions.service

systemctl reboot
