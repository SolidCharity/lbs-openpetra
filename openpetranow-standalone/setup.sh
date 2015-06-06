#!/bin/bash

#install the key from Xamarin
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"

yum install -y mono-complete nant dos2unix nsis gettext

tar xzf ~/sources/master.tar.gz
cd openpetra-master
export NSISDIR=/usr/local/nsis/
export PATH=$NSISDIR:$PATH
nant buildWindowsStandalone -D:OpenBuildService=true || exit -1

mkdir -p ~/repo/windows
cd delivery
for f in OpenPetraSetup-*.exe
do
  cp $f ~/repo/windows
  echo "download the installer at https://download.solidcharity.com/repos/tpokorra/openpetra/centos/7/windows/$f"
done
