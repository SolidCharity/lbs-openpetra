#!/bin/bash

# get our own mono packages
apt-get -y install apt-transport-https dirmngr gnupg ca-certificates
mkdir $HOME/.gnupg && chmod 700 $HOME/.gnupg
gpg --no-default-keyring --keyring /usr/share/keyrings/solidcharity-openpetra-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x4796B710919684AC
#echo 'deb [arch=amd64, signed-by=/usr/share/keyrings/solidcharity-openpetra-keyring.gpg] https://download.solidcharity.com/repos/tpokorra/mono/debian/buster buster main' > /etc/apt/sources.list.d/tpokorra-mono.list
echo 'deb [arch=amd64, signed-by=/usr/share/keyrings/solidcharity-openpetra-keyring.gpg] https://download.solidcharity.com/repos/tpokorra/nant/debian/bookworm bookworm main' > /etc/apt/sources.list.d/tpokorra-nant.list
apt-get update

apt-get -y install wget sudo mono-devel mono-xsp4 mono-fastcgi-server4 ca-certificates-mono xfonts-75dpi fonts-liberation libgdiplus nant nunit libsodium23 mariadb-server unzip git || exit -1

# to avoid errors like: error CS0433: The imported type `System.CodeDom.Compiler.CompilerError' is defined multiple times
if [ -f /usr/lib/mono/4.5-api/System.dll -a -f /usr/lib/mono/4.5/System.dll ]; then
  rm -f /usr/lib/mono/4.5-api/System.dll
fi

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
else
  echo "upload of databases is not configured"
  exit -1
fi

