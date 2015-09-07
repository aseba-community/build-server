#!/bin/sh
set -eu
cd `dirname "$0"`

#hdiutil makehybrid -iso -joliet -o osx/windows.iso windows
genisoimage -rational-rock -J -input-charset utf-8 -o osx/windows.iso windows

if [ ! -f osx/VBoxGuestAdditions.iso ]
then curl --output osx/VBoxGuestAdditions.iso http://download.virtualbox.org/virtualbox/5.0.2/VBoxGuestAdditions_5.0.2.iso
fi
