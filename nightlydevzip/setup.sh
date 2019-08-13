#!/bin/bash

branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi
ghubuser=openpetra
if [ ! -z "$2" ]; then
  ghubuser=$2
fi

# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
yum -y install mono-devel libgdiplus-devel xsp mono-mvc mono-data mono-data-sqlite liberation-mono-fonts nant wget tar sqlite php-cli curl gettext libsodium git

# get newer version of nant, to support mono-4.5 target framework
yum -y --enablerepo=epel-testing update nant

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

wget https://github.com/$ghubuser/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1

tar xzf sources.tar.gz
dir=$(find . -type d -name openpetra-*)
mv $dir nightlydevzip

cd nightlydevzip
cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
</project>
EOF

# remove the old 2.0.0.0 sqlite dll, replace with 4.5 dll
rm -Rf csharp/ThirdParty/SQLite/Mono.Data.Sqlite.dll
cp /usr/lib/mono/4.5/Mono.Data.Sqlite.dll csharp/ThirdParty/SQLite/

nant devzip || exit -1

mv ../openpetra_development_`date +"%Y-%m-%d"`.zip ~/tarball

# only upload builds of master
if [[ "$branch" == "master" ]]
then
  #upload to Github
  if [ -f ~/.ssh/github_config.php ]
  then
    php ../github_uploadrelease.php || exit -1
  fi
fi

rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d" --date='5 days ago'`.zip
rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d" --date='6 days ago'`.zip
rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d" --date='7 days ago'`.zip
echo download at https://download.solidcharity.com/tarballs/tpokorra/openpetra/openpetra_development_`date +"%Y-%m-%d"`.zip
