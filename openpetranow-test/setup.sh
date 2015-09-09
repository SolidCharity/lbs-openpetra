#!/bin/bash

branch=master
branch=20150909_release_2015-09
version=2015.08
if [ ! -z "$1" ]; then
  branch=$1
  version=`echo $branch | awk -F_ '{print $NF}' | sed -e 's#-#.#g'`
  version="$version.0"
  echo "calculated version: $version"
  if [ -z "$version" ]
  then
    echo "cannot make a version number out of $branch"
    exit -1
  fi
fi

yum install -y wget
if [[ "$branch" == "master" ]]
then
  wget https://github.com/openpetra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
else
  wget https://github.com/tpokorra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
fi

sed -i "s#%{BRANCH}#$branch#g" openpetranow-test.spec
sed -i "s#%{VERSION}#$version#g" openpetranow-test.spec

#install the key from Xamarin
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
