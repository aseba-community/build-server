#!/bin/sh
set -eu
cd `dirname "$0"`

RELEASE=$1
JENKINS_UID=$2
JENKINS_GID=$3

apt-get clean

groupadd --non-unique --gid "$JENKINS_GID" jenkins
useradd --non-unique --home /var/lib/jenkins --uid "$JENKINS_UID" --gid "$JENKINS_GID" jenkins

echo deb file:/var/lib/jenkins/userContent/debian "$RELEASE" origin/master > /etc/apt/sources.list.d/jenkins.list
