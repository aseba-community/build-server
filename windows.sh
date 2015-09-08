#!/bin/sh
set -eu
cd `dirname "$0"`

#hdiutil makehybrid -iso -joliet -o windows.iso windows
genisoimage -rational-rock -J -input-charset utf-8 -o windows.iso windows
