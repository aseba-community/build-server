#!/bin/sh
set -eu
cd `dirname "$0"`

#hdiutil makehybrid -iso -joliet -o osx/windows.iso windows
genisoimage -rational-rock -J -input-charset utf-8 -o osx/windows.iso windows
