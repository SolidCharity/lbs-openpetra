#!/bin/bash

. env.sh

if [ ! -z "$1" ]; then
  branch=$1
fi

yum install -y wget

if [[ $kindOfRelease =~ .*test ]]
then
  wget https://github.com/tpokorra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
else
  wget https://github.com/openpetra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
fi

wget https://github.com/openpetra/openpetra-i18n/archive/master.tar.gz -O i18n.tar.gz || exit -1

version=`tar xzf sources.tar.gz openpetra-$branch/db/version.txt -O | awk -F- '{print $1}'`

sed -i "s#%{BRANCH}#$branch#g" openpetranow-${kindOfRelease}.spec
sed -i "s#%{VERSION}#$version#g" openpetranow-${kindOfRelease}.spec
sed -i "s#%{KINDOFRELEASE}#${kindOfRelease}#g" openpetranow-${kindOfRelease}.spec
sed -i "s#%{URL}#${URL}#g" openpetranow-${kindOfRelease}.spec
