#!/bin/sh
set -eu
cd `dirname "$0"`

VBoxManage import windows.ovf --vsys 0 --vmname windows --vsys 0 --unit 10 --disk osx/windows.vmdk
