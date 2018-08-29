#!/bin/bash

branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi

yum install -y epel
yum install -y wget sudo mono-devel mono-mvc mono-winfxcore mono-wcf libgdiplus-devel nant NUnit xsp lsb libsodium \
  sqlite \
  liberation-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts liberation-serif-fonts liberation-sans-fonts

wget https://github.com/Holger-Will/code-128-font/raw/master/fonts/code128.ttf -O /usr/share/fonts/code128.ttf

# on Fedora 24, there is libsodium.so.18, on CentOS7 there is libsodium.so.13, and soon libsodium.so.23
cd /usr/lib64
if [ -f libsodium.so.18 ]
then
  ln -s libsodium.so.18 libsodium.so
elif [ -f libsodium.so.13 ]
then
  ln -s libsodium.so.13 libsodium.so
elif [ -f libsodium.so.23 ]
then
  ln -s libsodium.so.23 libsodium.so
elif [ -f libsodium.so ]
then
  echo "there is already a libsodium.so"
else
  echo "cannot create link for libsodium.so"
  exit -1
fi
cd -

if [[ "$branch" == "master" ]]
then
  wget https://github.com/openpetra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
else
  wget https://github.com/tbits/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
fi

tar xzf sources.tar.gz || exit -1
openpetradir=$(find . -type d -name openpetra-*)

if [[ "$branch" == "master" ]]
then
  wget https://github.com/openpetra/openpetra-client-js/archive/$branch.tar.gz -O sources-client.tar.gz || exit -1
else
  wget https://github.com/tbits/openpetra-client-js/archive/$branch.tar.gz -O sources-client.tar.gz || exit -1
fi

tar xzf sources-client.tar.gz || exit -1
openpetraclientdir=$(find . -type d -name openpetra-client-js*)
if [ ! -d "openpetra-client-js" ]
then
  mv $openpetraclientdir openpetra-client-js
  openpetraclientdir="openpetra-client-js"
fi

cd $openpetradir

cat > OpenPetra.build.config <<FINISH
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
</project>
FINISH

nant generateTools || exit -1
nant generateORM || exit -1
nant recreateDatabase resetDatabase || exit -1
nant generateSolution || exit -1

# need this for the tests
wget https://github.com/openpetra/demo-databases/raw/UsedForNUnitTests/demoWith1ledger.yml.gz || exit -1

nant test-without-display || exit -1

nant checkHtml || exit -1
