#!/bin/bash

# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
dnf -y install mono-core mono-devel libgdiplus-devel nant wget tar sqlite sql2diagram dia openssh-clients || exit 1

wget https://github.com/openpetra/openpetra/archive/master.tar.gz
tar xzf master.tar.gz
cd openpetra-master

cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
    <property name="sql2dia" value="sql2dia" overwrite="false"/>
</project>
EOF

nant generateTools dbdoc || exit -1
# need to run twice, so that the diagrams can be picked up
nant dbdoc || exit -1

cd delivery/dbdoc
rm -Rf bak
rm -Rf *.bat
cd ..

#upload to Hostsharing
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  rsync -avz --delete -e "ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/id_rsa_cronjob" dbdoc tim00-openpetra@tim00.hostsharing.net:.
fi

