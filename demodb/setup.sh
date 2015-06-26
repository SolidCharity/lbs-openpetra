#!/bin/bash

dnf -y install mono-core mono-devel libgdiplus-devel xsp nant wget tar sqlite unzip || exit -1

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

# apply a patch so that starting and stopping works on Linux and Mono
patch -p1 < ../OpenPetra.default.targets.xml.patch

nant minimalGenerateSolution || exit -1
# csharp/ThirdParty/SQLite/Mono.Data.Sqlite.dll still references .Net 2.0
# if we compile against it, we cannot start the server with sqlite because it searches for the wrong dll
rm csharp/ThirdParty/SQLite/Mono.Data.Sqlite.dll
find . -name "*.csproj" -print -exec sed -i 's#<HintPath>.*ThirdParty/SQLite/Mono\.Data\.Sqlite\.dll</HintPath>##g' {} \;
nant quickCompile recreateDatabase initConfigFiles || exit -1

function SaveYmlGzDatabase
{
ymlgzfile=$1

  nant startServer
  sleep 3
  cd delivery/bin
  mono PetraServerAdminConsole.exe -C:../../etc/ServerAdmin.config -Command:SaveYmlGz -YmlGzFile:../../$ymlgzfile || exit -1
  cd ../../
  nant stopServer
}

# create the base database
nant resetDatabase || exit -1
SaveYmlGzDatabase base.yml.gz

# create a database with one ledger with one year of data
nant resetDatabase importDemodata || exit -1
SaveYmlGzDatabase demoWith1ledger.yml.gz

# create a database with a ledger with several years
nant resetDatabase importDemodata -D:operation=ledgerMultipleYears || exit -1
SaveYmlGzDatabase demoMultipleYears.yml.gz

# add a second ledger
nant importDemodata -D:operation=secondLedger || exit -1
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

