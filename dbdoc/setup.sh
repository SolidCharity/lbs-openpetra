#!/bin/bash

yum -y install mono-opt mono-opt-devel mono-nant-opt wget tar sqlite sql2diagram
. /opt/mono/env.sh

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

cd delivery/dbdoc
rm -Rf bak
rm -Rf *.bat
tar czf ../dbdoc.tar.gz .

#upload to dbdoc.openpetra.org
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  echo "put ../dbdoc.tar.gz" | sftp -o StrictHostKeyChecking=no -oPort=2033 upload@dbdoc.openpetra.org:dbdoc || exit -1
  ssh -o StrictHostKeyChecking=no -oPort=2033 upload@dbdoc.openpetra.org -c "cd dbdoc; tar xzf dbdoc.tar.gz" || exit -1
  kill $SSH_AGENT_PID
fi

