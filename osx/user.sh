#!/bin/sh

# allow ssh key-based login
cp authorized_keys ~/.ssh/authorized_keys

# setup linux VM
VBoxManage createvm --name linux --ostype RedHat_64 --register
VBoxManage modifyvm linux\
 --cpus 2\
 --memory 4096\
 --vram 16\
 --nictype1 virtio\
 --natpf1 sshd,tcp,,2222,,22\
 --natpf1 jenkins,tcp,,8080,,8080\
 --boot1 disk\
 --boot2 none\
 --boot3 none
VBoxManage storagectl linux --name SATA --add sata
VBoxManage storageattach linux --storagectl SATA --port 0 --type hdd --medium linux.vdi

# install WebViewScreenSaver
if [ ! -f WebViewScreenSaver.zip ]
then curl --location --output WebViewScreenSaver.zip https://github.com/liquidx/webviewscreensaver/releases/download/v2.0/WebViewScreenSaver-2.0.zip
fi
mkdir -p "$HOME/Library/Screen Savers"
unzip WebViewScreenSaver.zip -d "$HOME/Library/Screen Savers"
#TODO: setup WebViewScreenSaver

# setup login items
mkdir -p "$HOME/Library/LaunchAgents"
cp *.plist "$HOME/Library/LaunchAgents/"
