#!/bin/bash

user=op_dev
dbms=mysql
branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi
ghubuser=openpetra
if [ ! -z "$2" ]; then
  ghubuser=$2
fi

git_url=https://github.com/openpetra/$ghubuser.git

set -o pipefail
curl https://get.openpetra.org | bash -s devenv --git_url=$git_url --branch=$branch --dbms=$dbms --iknowwhatiamdoing=yes || exit -1

cd /home/$user/openpetra

versionWithoutBuild=`cat db/version.txt | sed -e "s/-/./g" | awk -F '.' '{print $1 "." $2 "." $3}'`
prevTarball=`curl https://download.solidcharity.com/tarballs/solidcharity/openpetra/latest.txt`
prevVersion=`echo $prevTarball | awk -F '-' '{print $2}'`
prevVersionWithoutBuild=`echo $prevVersion | awk -F '.' '{print $1 "." $2 "." $3}'`
if [[ "$versionWithoutBuild" == "$prevVersionWithoutBuild" ]]; then
  # increase the build number
  buildnumber=`echo $prevVersion | awk -F '.' '{print $4}'`
  buildnumber=$((buildnumber+1))
else
  buildnumber=0
fi
versionWithBuild="$versionWithoutBuild.$buildnumber"

echo $versionWithBuild > db/pkg_version.txt
tarball="openpetra-$versionWithBuild-bin.tar.gz"
su $user -c "BUILD_NUMBER=$buildnumber nant buildRelease -D:OnlyTarball=true -D:tarfile=$tarball" || exit -1

mv /home/$user/openpetra/delivery/$tarball ~/tarball
echo "$tarball" > ~/tarball/latest.txt

echo "DONE with building the tarball for " $branch
echo "download at https://download.solidcharity.com/tarballs/solidcharity/openpetra/$tarball"

# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo

