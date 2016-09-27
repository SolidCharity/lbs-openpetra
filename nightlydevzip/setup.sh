#!/bin/bash

branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi

# get the key for the Xamarin packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
yum -y install mono-devel libgdiplus-devel xsp mono-mvc mono-data-sqlite liberation-mono-fonts nant wget tar sqlite php-cli curl gettext libsodium

# on Fedora 24, there is libsodium.so.18
cd /usr/lib64
ln -s libsodium.so.18 libsodium.so
cd -

if [[ "$branch" == "master" ]]
then
  wget https://github.com/openpetra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
else
  wget https://github.com/tpokorra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
fi

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

if [[ "$branch" == "master" ]]
then
  # only upload builds of master
  mv ../openpetra_development_`date +"%Y-%m-%d"`.zip ~/tarball

  #upload to Github
  if [ -f ~/.ssh/github_config.php ]
  then
    php ../github_uploadrelease.php || exit -1
  fi

  rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d" --date='6 days ago'`.zip
  echo download at https://download.solidcharity.com/tarballs/tpokorra/openpetra/openpetra_development_`date +"%Y-%m-%d"`.zip
fi
