#!/bin/bash

# get the key for the Xamarin packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
yum -y install mono-devel libgdiplus-devel xsp mono-mvc mono-data-sqlite liberation-mono-fonts nant wget tar sqlite php-cli curl gettext

wget https://github.com/openpetra/openpetra/archive/master.tar.gz || exit -1
tar xzf master.tar.gz
mv openpetra-master nightlydevzip
#wget https://github.com/tpokorra/openpetra/archive/mono4.tar.gz || exit -1
#tar xzf mono4.tar.gz
#mv openpetra-mono4 nightlydevzip

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

#upload to Github
if [ -f ~/.ssh/github_config.php ]
then
  php ../github_uploadrelease.php || exit -1
fi

rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d" --date='6 days ago'`.zip
echo download at https://download.solidcharity.com/tarballs/tpokorra/openpetra/openpetra_development_`date +"%Y-%m-%d"`.zip
