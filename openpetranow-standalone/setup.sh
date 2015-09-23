#!/bin/bash

. env.sh

if [ ! -z "$1" ]; then
  branch=$1
  version=`echo $branch | awk -F_ '{print $NF}' | sed -e 's#-#.#g'`
  version="$version.$subversion"
  echo "calculated version: $version"
  if [ -z "$version" ]
  then
    echo "cannot make a version number out of $branch"
    exit -1
  fi
fi

#install the key from Xamarin
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"

yum install -y mono-complete nant dos2unix nsis gettext patch wget

wget $giturl/$branch.tar.gz -O sources.tar.gz || exit -1

tar xzf sources.tar.gz
dir=$(find . -type d -name openpetra-*)
cd $dir
nant translation
export NSISDIR=/usr/local/nsis/
export PATH=$NSISDIR:$PATH
if [[ "$branch" == "master" ]]
then
  version=`cat db/version.txt`
fi
nant buildWindowsStandalone -D:OpenBuildService=true -D:ReleaseID=$version || exit -1

mkdir -p ~/repo/$path/$branch
cd delivery
for f in OpenPetraSetup-*.exe
do
  cp $f ~/repo/$path/$branch
  echo "download the installer at https://download.solidcharity.com/repos/tpokorra/openpetra/centos/7/$path/$branch/$f"
done
