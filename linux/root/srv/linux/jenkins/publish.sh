#!/bin/sh
set -eu

cd debian
for file in `find -name Packages`
do dir=`dirname "$file"`
dpkg-scanpackages "$dir" > "$file"
done
cd ..

lftp << EOF
set ssl:verify-certificate false
open mobots.epfl.ch
cd htdocs/data/aseba-build-server
mirror --reverse
EOF
