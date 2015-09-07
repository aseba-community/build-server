# install VirtualBox guest additions
Invoke-WebRequest -Uri http://download.virtualbox.org/virtualbox/5.0.2/VBoxGuestAdditions_5.0.2.iso -OutFile VBoxGuestAdditions.iso
Mount-DiskImage -ImagePath $PWD\VBoxGuestAdditions.iso
& F:\cert\VBoxCertUtil.exe add-trusted-publisher F:\cert\oracle-vbox.cer --root F:\cert\oracle-vbox.cer
& F:\VBoxWindowsAdditions.exe /S
Dismount-DiskImage -ImagePath $PWD\VBoxGuestAdditions.iso

# install 7zip
Invoke-WebRequest -Uri http://www.7-zip.org/a/7z920-x64.msi -OutFile 7z-x64.msi
& .\7z-x64.msi

# install java
$cookie = New-Object System.Net.Cookie
$cookie.Name = "oraclelicense"
$cookie.Value = "a"
$cookie.Domain = "oracle.com"
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$webSession.Cookies.Add($cookie)
Invoke-WebRequest -Uri http://download.oracle.com/otn-pub/java/jdk/8u60-b27/server-jre-8u60-windows-x64.tar.gz -WebSession $webSession -OutFile server-jre-windows-x64.tar.gz
& "C:\Program Files\7-Zip\7z.exe" x server-jre-windows-x64.tar.gz
& "C:\Program Files\7-Zip\7z.exe" x server-jre-windows-x64.tar

# setup jenkins slave
Invoke-WebRequest -Uri http://stidhcp-1-064.epfl.ch:8080/jnlpJars/slave.jar -OutFile slave.jar
$jenkinsSlaveXml = Get-Content -Path E:\jenkins-slave.xml -Raw
Register-ScheduledTask -TaskName "jenkins-slave" -Xml $jenkinsSlaveXml

Restart-Computer
