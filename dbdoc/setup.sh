#!/bin/bash

yum -y install mono-opt mono-opt-devel mono-nant-opt wget tar sqlite sql2diagram dia
. /opt/mono/env.sh

#wget https://github.com/openpetra/openpetra/archive/master.tar.gz
wget https://github.com/tpokorra/openpetra/archive/master.tar.gz
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

cd delivery/dbdoc
rm -Rf bak
rm -Rf *.bat
tar czf ../dbdoc.tar.gz .

#upload to dbdoc.openpetra.org
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  echo "put ../dbdoc.tar.gz" | sftp -o StrictHostKeyChecking=no upload@10.0.3.33:dbdoc || exit -1
  ssh -o StrictHostKeyChecking=no upload@10.0.3.33 "cd dbdoc; tar xzf dbdoc.tar.gz" || exit -1
  kill $SSH_AGENT_PID
fi

