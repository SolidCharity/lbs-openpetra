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

curl https://get.openpetra.org | bash -s devenv --git_url=$git_url --branch=$branch --dbms=$dbms --iknowwhatiamdoing=yes || exit -1

cd /home/$user/openpetra

su $user -c "nant buildRelease -D:OnlyTarball=true" || exit -1

for f in /home/$user/openpetra/delivery/openpetra-*-bin.tar.gz; do
  tarball=`basename $f`
  mv $f ~/tarball
done

echo "DONE with building the tarball for " $branch
echo "download at https://download.solidcharity.com/tarballs/solidcharity/openpetra/$tarball"

# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo

