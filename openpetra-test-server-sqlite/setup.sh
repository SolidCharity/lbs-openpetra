#!/bin/bash

branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi

yum install -y epel
#install the key from Xamarin
#rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
yum install -y wget sudo mono-devel mono-mvc mono-winfx mono-wcf libgdiplus-devel liberation-mono-fonts nant NUnit xsp sqlite lsb libsodium

# on CentOS7, there is libsodium.so.13
cd /usr/lib64
ln -s libsodium.so.13 libsodium.so
cd -

if [[ "$branch" == "master" ]]
then
  wget https://github.com/openpetra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
else
  wget https://github.com/tpokorra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
fi

tar xzf sources.tar.gz || exit -1
dir=$(find . -type d -name openpetra-*)
cd $dir

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
