#!/bin/bash

#install the key from Xamarin
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"

yum install -y mono-complete nant dos2unix nsis gettext patch

tar xzf ~/sources/test.tar.gz
dir=$(find . -type d -name openpetra-*)
cd $dir
export NSISDIR=/usr/local/nsis/
export PATH=$NSISDIR:$PATH
nant buildWindowsStandalone -D:OpenBuildService=true || exit -1

path=windows/openpetranow-standalone-test
mkdir -p ~/repo/$path
cd delivery
for f in OpenPetraSetup-*.exe
do
  cp $f ~/repo/$path
  echo "download the installer at https://download.solidcharity.com/repos/tpokorra/openpetra/centos/7/$path/$f"
done