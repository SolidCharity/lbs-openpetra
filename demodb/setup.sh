#!/bin/bash

dnf -y install mono-core mono-devel nant wget tar sqlite unzip || exit -1

#repoowner=openpetra
#branch=master
repoowner=tpokorra
branch=201506_prepare_release
wget https://github.com/$repoowner/openpetra/archive/$branch.tar.gz
tar xzf $branch.tar.gz
cd openpetra-$branch

cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
</project>
EOF

wget http://sourceforge.net/projects/openpetraorg/files/openpetraorg/demodata/generatedDataUsedForDemodatabases.zip/download -O generatedDataUsedForDemodatabases.zip

mkdir -p demodata/generated
cd demodata/generated
unzip ../../generatedDataUsedForDemodatabases.zip
cd ../../

nant quickClean deleteBakFiles generateTools recreateDatabase || exit -1

function SaveYmlGzDatabase
{
ymlgzfile=$1

  nant startServer
  cd delivery/bin
  mono PetraServerAdminConsole.exe -C:../../etc/PetraServerAdminConsole.config -Command:SaveYmlGz -YmlGzFile:../../$ymlgzfile
  cd ../../
  nant stopServer
}

# create the base database
nant resetDatabase
SaveYmlGzDatabase base.yml.gz

# create a database with one ledger with one year of data
nant resetDatabase importDemodata
SaveYmlGzDatabase demoWith1ledger.yml.gz

# create a database with a ledger with several years
nant resetDatabase importDemodata -D:operation=ledgerMultipleYears
SaveYmlGzDatabase demoMultipleYears.yml.gz

# add a second ledger
nant importDemodata -D:operation=secondLedger
SaveYmlGzDatabase demoWith2ledgers.yml.gz

#upload to Sourceforge
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  echo "put base.yml.gz" | sftp -o StrictHostKeyChecking=no pokorra@frs.sourceforge.net:/home/frs/project/openpetraorg/openpetraorg/demodata || exit -1
  echo "put demo*.yml.gz" | sftp -o StrictHostKeyChecking=no pokorra@frs.sourceforge.net:/home/frs/project/openpetraorg/openpetraorg/demodata || exit -1
  kill $SSH_AGENT_PID
fi

