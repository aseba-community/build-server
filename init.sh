#!/usr/bin/sudo -i sh
set -eu
cd `dirname "$0"`

USER=administrator

# enable ssh login
cp authorized_keys ~/.ssh/authorized_keys
launchctl load -w /System/Library/LaunchDaemons/ssh.plist

# setup networking
networksetup -setmanual Ethernet 128.178.145.91 255.255.255.0 128.178.145.1
networksetup -setdnsservers Ethernet 128.178.15.8 128.178.15.7

# disable sleep, keep screen on for 3h
pmset -a sleep 0
pmset -a displaysleep 180

# set hostname
HOSTNAME=aseba-build-server
scutil --set ComputerName "$HOSTNAME"
scutil --set HostName "$HOSTNAME"
scutil --set LocalHostName "$HOSTNAME"
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$HOSTNAME"

# install VirtualBox
if [ ! -f VirtualBox.dmg ]
then curl --output VirtualBox.dmg http://download.virtualbox.org/virtualbox/5.0.2/VirtualBox-5.0.2-102096-OSX.dmg
fi
hdiutil attach VirtualBox.dmg
installer -package /Volumes/VirtualBox/VirtualBox.pkg -target /
hdiutil detach /Volumes/VirtualBox

# install JDK
if [ ! -f jdk-macosx-x64.dmg ]
then curl --cookie oraclelicense=a --location --output jdk-macosx-x64.dmg http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-macosx-x64.dmg
fi
hdiutil attach jdk-macosx-x64.dmg
installer -package "/Volumes/JDK 8 Update 60/JDK 8 Update 60.pkg" -target /
hdiutil detach "/Volumes/JDK 8 Update 60"

# setup user
sudo -i -u "$USER" "$PWD/user.sh"

# login automatically
defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser "$USER"

# ask for password when exiting screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# install updates
softwareupdate --install --all

reboot
