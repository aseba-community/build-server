#!/bin/sh
set -eu
cd `dirname "$0"`

# allow ssh key-based login
cp authorized_keys ~/.ssh/authorized_keys

# setup linux VM
if [ ! -f CentOS-7-x86_64-GenericCloud.raw ]
then curl --output CentOS-7-x86_64-GenericCloud.raw http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1510.raw
fi
VBoxManage convertfromraw CentOS-7-x86_64-GenericCloud.raw linux.vdi
#qemu-img convert -O vdi CentOS-7-x86_64-GenericCloud-1510.qcow2 linux.vdi
VBoxManage modifyhd linux.vdi --resize 65536
(cd linux/root && tar -c `ls`) | cat linux/user-data.sh - > linux/cidata/user-data
hdiutil makehybrid -iso -joliet -default-volume-name cidata -o linux.iso linux/cidata
#genisoimage -rock -joliet -volid cidata -output linux.iso linux/cidata
VBoxManage createvm --name linux --ostype RedHat_64 --register
VBoxManage modifyvm linux\
 --cpus 2\
 --memory 4096\
 --vram 64\
 --nictype1 virtio\
 --natpf1 sshd,tcp,,2222,,22\
 --natpf1 jenkins,tcp,,8080,,8080\
 --natpf1 jenkins-slave-agent,tcp,,5143,,5143\
 --boot1 disk\
 --boot2 none\
 --boot3 none
VBoxManage storagectl linux --name SATA --add sata
VBoxManage storageattach linux --storagectl SATA --port 0 --type hdd --medium linux.vdi
VBoxManage storageattach linux --storagectl SATA --port 1 --type dvddrive --medium linux.iso

# setup windows VM
hdiutil makehybrid -iso -joliet -o windows.iso windows
#genisoimage -rock -joliet -output windows.iso windows
VBoxManage createvm --name windows --ostype Windows2012_64 --register
VBoxManage modifyvm windows\
 --cpus 1\
 --memory 2048\
 --vram 64\
 --boot1 dvd\
 --boot2 disk\
 --boot3 none
VBoxManage storagectl windows --name SATA --add sata
VBoxManage createhd --filename windows.vdi --size 32768
VBoxManage storageattach windows --storagectl SATA --port 0 --type hdd --medium windows.vdi
VBoxManage storageattach windows --storagectl SATA --port 1 --type dvddrive --medium SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-3_MLF_X19-53588.iso
VBoxManage storageattach windows --storagectl SATA --port 2 --type dvddrive --medium windows.iso

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
