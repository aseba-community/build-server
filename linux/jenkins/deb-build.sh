#!/bin/sh
set -eu

WORKSPACE=$1
BUILD_ID=$2

cd "$WORKSPACE/source"

if command -v gbp
then gbp dch --since=HEAD --snapshot "--snapshot-number=$BUILD_ID"
# precise has dch as a git subcommand
else git dch --since=HEAD --snapshot "--snapshot-number=$BUILD_ID"
fi

git commit --message "build #$BUILD_ID" debian/changelog
