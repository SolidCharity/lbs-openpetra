#!/bin/bash

. env.sh

branch=master

if [ ! -z "$1" ]; then
  branch=$1
fi

yum install -y mono-devel libgdiplus-devel liberation-mono-fonts nant dos2unix nsis gettext patch wget

if [[ "$kindOfRelease" == "test" ]]
then
  wget https://github.com/tpokorra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
else
  wget https://github.com/openpetra/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1
fi

tar xzf sources.tar.gz || exit -1
srcdir="/root/sources"
dir=$(find . -type d -name openpetra-*)

(tar xzf $srcdir/plugin_bankimport.tar.gz && mv OpenPetraPlugin_Bankimport-master $dir/csharp/ICT/Petra/Plugins/Bankimport) || exit -1
(tar xzf $srcdir/plugin_bankimport_csv.tar.gz && mv OpenPetraPlugin_BankimportCSV-master $dir/csharp/ICT/Petra/Plugins/BankimportCSV) || exit -1
(tar xzf $srcdir/plugin_bankimport_mt940.tar.gz && mv OpenPetraPlugin_BankimportMT940-master $dir/csharp/ICT/Petra/Plugins/BankimportMT940) || exit -1
(tar xzf $srcdir/plugin_bankimport_camt.tar.gz && mv OpenPetraPlugin_BankimportCAMT-master $dir/csharp/ICT/Petra/Plugins/BankimportCAMT) || exit -1

tar xzf $srcdir/i18n.tar.gz || exit -1
mv openpetra-i18n-master/i18n/de.po $dir/i18n/de_DE.po || exit -1
mv openpetra-i18n-master/i18n/es.po $dir/i18n/es_ES.po || exit -1
mv openpetra-i18n-master/i18n/da.po $dir/i18n/da_DK.po || exit -1

cd $dir
export NSISDIR=/usr/share/nsis/
export PATH=$NSISDIR:$PATH
version=`cat db/version.txt | awk -F- '{print $1}'`

newrelease=0
if [ -d ~/repo/$path/$branch ]
then
  for f in ~/repo/$path/$branch/OpenPetraSetup-$version.*.exe
  do
    if [ ! -f "$f" ]
    then
      break;
    fi
    release=`basename $f | awk -F. '{print $4}'`
    if [ $release -ge $newrelease ]
    then
      newrelease=$((release+1))
    fi
  done
fi
version=$version"."$newrelease

nant buildWindowsStandalone -D:OpenBuildService=true -D:ReleaseID=$version || exit -1

mkdir -p ~/repo/$path/$branch
cd delivery
for f in OpenPetraSetup-*.exe
do
  cp $f ~/repo/$path/$branch
  echo "download the installer at https://download.solidcharity.com/repos/tpokorra/openpetra/centos/7/$path/$branch/$f"
done
