#!/bin/sh
set -eu

WORKSPACE=$1
BUILD_ID=$2

cd "$WORKSPACE/source"

git-dch --since=HEAD --snapshot "--snapshot-number=$BUILD_ID"
git commit --message "build #$BUILD_ID" debian/changelog
