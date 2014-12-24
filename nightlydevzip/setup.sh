#!/bin/bash

yum -y install mono-xsp-opt mono-opt-devel mono-nant-opt wget tar sqlite
. /opt/mono/env.sh
wget https://github.com/openpetra/openpetra/archive/master.tar.gz
tar xzf master.tar.gz
mv openpetra-master nightlydevzip

cd nightlydevzip
cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
</project>
EOF
patch -p1 --ignore-whitespace < ../devzip.patch
nant devzip

mv ../openpetra_development_`date +"%Y-%m-%d"`.zip ~/tarball
echo download at http://download.lbs.solidcharity.com/tarballs/tpokorra/openpetra/openpetra_development_`date +"%Y-%m-%d"`.zip
