#!/bin/bash

. env.sh

if [ ! -z "$1" ]; then
  branch=$1
  if [[ "$branch" != "master" ]]
  then
    version=`echo $branch | awk -F_ '{print $NF}' | sed -e 's#-#.#g'`
    echo "calculated version: $version"
    if [ -z "$version" ]
    then
      echo "cannot make a version number out of $branch"
      exit -1
    fi
  fi
fi

yum install -y wget

wget $giturl/$branch.tar.gz -O sources.tar.gz || exit -1
wget https://github.com/openpetra/openpetra-i18n/archive/master.tar.gz -O i18n.tar.gz || exit -1

if [[ "$branch" == "master" ]]
then
  version=`tar xzf sources.tar.gz openpetra-master/db/version.txt -O | awk -F- '{print $1}'`
fi

sed -i "s#%{BRANCH}#$branch#g" openpetranow-${kindOfRelease}.spec
sed -i "s#%{VERSION}#$version#g" openpetranow-${kindOfRelease}.spec
sed -i "s#%{KINDOFRELEASE}#${kindOfRelease}#g" openpetranow-${kindOfRelease}.spec

#install the key from Xamarin
#rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
