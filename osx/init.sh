#!/bin/sh

cp authorized_keys ~/.ssh/authorized_keys

# set hostname
HOSTNAME=aseba-build-server
scutil --set ComputerName "$HOSTNAME"
scutil --set HostName "$HOSTNAME"
scutil --set LocalHostName "$HOSTNAME"
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$HOSTNAME"

# prevent sleep
pmset -a sleep 0

if [ ! -f VirtualBox.dmg ]
then curl --output VirtualBox.dmg http://download.virtualbox.org/virtualbox/5.0.2/VirtualBox-5.0.2-102096-OSX.dmg
fi
hdiutil attach VirtualBox.dmg
installer -package /Volumes/VirtualBox/VirtualBox.pkg -target /
hdiutil detach /Volumes/VirtualBox

if [ ! -f jdk-macosx-x64.dmg ]
then curl --cookie oraclelicense=a --location --output jdk-macosx-x64.dmg http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-macosx-x64.dmg
fi
hdiutil attach jdk-macosx-x64.dmg
installer -package "/Volumes/JDK 8 Update 60/JDK 8 Update 60.pkg" -target /
hdiutil detach "/Volumes/JDK 8 Update 60"

mkdir -p /etc/vbox
cat > /etc/vbox/autostart.cfg << EOF
default_policy = deny
administrator = {
	allow = true
}
EOF
cp /Applications/VirtualBox.app/Contents/MacOS/org.virtualbox.vboxautostart.plist /Library/LaunchDaemons/
launchctl load -w /Library/LaunchDaemons/org.virtualbox.vboxautostart.plist

sudo -i -u administrator << EOF
VBoxManage registervm build-linux/build-linux.vbox
VBoxManage modifyvm build-linux --autostart-enabled on
EOF

softwareupdate --install --all

reboot
