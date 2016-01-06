#!/bin/sh
sed "--expression=1,/^exit$/d" "$0" | tar --extract --no-same-owner --no-same-permissions
systemctl start init.service
exit
