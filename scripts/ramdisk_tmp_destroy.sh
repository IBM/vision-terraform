#!/bin/bash -e
BASEDIR="$(dirname "$0")"
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh

sudo umount -lf /tmp/ramdisk
echo "INFO: Unmounted ramdisk - deleting away any temp files"
