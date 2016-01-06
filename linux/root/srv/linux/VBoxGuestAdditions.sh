#!/bin/sh
set -eu
cd `dirname "$0"`

curl --output /tmp/VBoxGuestAdditions.iso http://download.virtualbox.org/virtualbox/5.0.12/VBoxGuestAdditions_5.0.12.iso
mkdir /tmp/VBoxGuestAdditions
mount --options loop /tmp/VBoxGuestAdditions.iso /tmp/VBoxGuestAdditions
REMOVE_INSTALLATION_DIR=0 /tmp/VBoxGuestAdditions/VBoxLinuxAdditions.run
