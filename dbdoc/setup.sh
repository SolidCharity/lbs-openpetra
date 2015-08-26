#!/bin/bash

# get the key for the Xamarin packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
yum -y install mono-core nant wget tar sqlite sql2diagram dia || exit 1

wget https://github.com/openpetra/openpetra/archive/master.tar.gz
#wget https://github.com/tpokorra/openpetra/archive/master.tar.gz
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
tar czf ../dbdoc.tar.gz .

#upload to dbdoc.openpetra.org
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  localmachine=1
  echo "put ../dbdoc.tar.gz" | sftp -o StrictHostKeyChecking=no upload@10.0.3.33:dbdoc || localmachine=0
  if [ $localmachine = 1 ]
  then
    ssh -o StrictHostKeyChecking=no upload@10.0.3.33 "cd dbdoc; tar xzf dbdoc.tar.gz" || exit -1
  else
    echo "put ../dbdoc.tar.gz" | sftp -o StrictHostKeyChecking=no -oPort=2033 upload@dbdoc.openpetra.org:dbdoc || exit -1
    ssh -o StrictHostKeyChecking=no -p 2033 upload@dbdoc.openpetra.org "cd dbdoc; tar xzf dbdoc.tar.gz" || exit -1
  fi
  kill $SSH_AGENT_PID
fi

