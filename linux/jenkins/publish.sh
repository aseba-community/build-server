#!/bin/sh
set -eu

cd "$JENKINS_HOME/userContent"

lftp << EOF
set ssl:verify-certificate false
open mobots.epfl.ch
cd htdocs/data/aseba-build-server
mirror --reverse
EOF
