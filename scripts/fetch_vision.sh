#!/bin/bash -e
BASEDIR="$(dirname "$0")"
# shellcheck disable=SC2034
# shellcheck disable=SC2034
# shellcheck disable=SC1090
source ${BASEDIR}/env.sh
echo "Installing aria2..."
apt-get -qq -o Dpkg::Use-Pty=0 update || echo " RC${?} Got an error on update???"
apt-get -qq -o Dpkg::Use-Pty=0 -y install aria2
echo "Downloading to ${RAMDISK}..."
pushd $RAMDISK
echo "Fetching  image tarball..."
#Use xargs to pass the stdout of the signing script to aria2c as an arugment
python3 $BASEDIR/sign.py --url $URLPAIVIMAGES | xargs -t aria2c -s160 -x16 $URLPAIVIMAGES
echo "Fetching deb"
python3 $BASEDIR/sign.py --url $URLPAIVDEB | xargs -t aria2c $URLPAIVDEB
echo "Uninstalling aria2"
apt-get -qq -o Dpkg::Use-Pty=0 -y remove aria2
echo "SUCCESS: Files downloaded successfully!"
popd
