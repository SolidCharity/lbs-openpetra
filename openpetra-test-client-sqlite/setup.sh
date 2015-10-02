#!/bin/bash

branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi

yum install -y epel
#install the key from Xamarin
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
yum install -y wget sudo mono mono-mvc mono-wcf nant NUnit xsp sqlite lsb
yum install -y xorg-x11-server-Xvfb patch

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

/usr/bin/Xvfb :99 -screen 0 1024x768x24 -fbdir /var/run -ac >& /dev/null &
export DISPLAY=:99
nant test-client || exit -1
