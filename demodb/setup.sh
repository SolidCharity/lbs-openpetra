#!/bin/bash

yum install -y wget sudo mono-devel mono-data mono-mvc mono-winfxcore mono-wcf mono-winfx libgdiplus-devel nant nunit xsp lsb libsodium \
  mariadb-server \
  nant tar sqlite unzip sudo git || exit -1

systemctl start mariadb
systemctl enable mariadb

ghubuser=openpetra
branch=test
wget https://github.com/$ghubuser/openpetra/archive/$branch.tar.gz
tar xzf $branch.tar.gz
cd openpetra-$branch

generatedData=https://github.com/openpetra/demo-databases/archive/master.tar.gz
wget $generatedData -O demodata.tar.gz
tar xzf demodata.tar.gz

mkdir -p demodata/generated
mv demo-databases-master/generatedDataUsedForDemodatabases/*.csv demodata/generated
rm -Rf demo-databases-master

# on Fedora 24, there is libsodium.so.18, on CentOS7 there is libsodium.so.23
cd /usr/lib64
if [ -f libsodium.so.18 ]
then
  ln -s libsodium.so.18 libsodium.so
elif [ -f libsodium.so.23 ]
then
  ln -s libsodium.so.23 libsodium.so
elif [ -f libsodium.so ]
then
  echo "there is already a libsodium.so"
else
  echo "cannot create link for libsodium.so"
  exit -1
fi
cd -

cat > OpenPetra.build.config <<FINISH
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="mysql"/>
    <property name="DBMS.RootPassword" value=""/>
</project>
FINISH

# avoid error during createDatabaseUser: sudo: sorry, you must have a tty to run sudo
sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers

nant generateSolution initConfigFiles copySQLFiles || exit -1
nant createDatabaseUser || exit -1
nant recreateDatabase || exit -1

function SaveYmlGzDatabase
{
ymlgzfile=$1

  cd delivery/bin
  mono Ict.Petra.Tools.MSysMan.YmlGzImportExport.exe -C:../../etc/TestServer.config  -Action:dump -YmlGzFile:../../$ymlgzfile || exit -1
  cd -
}

# create the base database
nant resetDatabase -D:WithDemoDataGermany=true || exit -1
SaveYmlGzDatabase base.yml.gz

# create the clean database (only SYSADMIN user, currency and other tables, but no partners, no ledger)
nant resetDatabase -D:WithDemoDataGermany=false || exit -1
SaveYmlGzDatabase clean.yml.gz

# create a database with one ledger with one year of data
nant resetDatabase importDemodata || exit -1
SaveYmlGzDatabase demoWith1ledger.yml.gz

# create a database with a ledger with several years
nant resetDatabase importDemodata -D:operation=ledgerMultipleYears || exit -1
SaveYmlGzDatabase demoMultipleYears.yml.gz

# add a second ledger
nant importDemodata -D:operation=secondLedger || exit -1
SaveYmlGzDatabase demoWith2ledgers.yml.gz

#upload to Github
if [ -f ~/.ssh/gitkey ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/gitkey
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  git clone --depth 1 git@github.com:openpetra/demo-databases.git || exit -1

  alias cp=cp
  cp -f base.yml.gz demo-databases
  cp -f clean.yml.gz demo-databases
  cp -f demo*.yml.gz demo-databases
  cd demo-databases
  msg="commit latest demo databases `date +%Y%m%d`"
  git add *.yml.gz
  git config --global user.name "LBS BuildBot"
  git config --global user.email "buildbot@lbs.solidcharity.com"
  git commit -a -m "$msg" || exit -1
  git push || exit -1
  kill $SSH_AGENT_PID
fi

