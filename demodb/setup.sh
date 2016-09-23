#!/bin/bash

# get the key for the Xamarin packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
dnf -y install mono-core mono-devel libgdiplus-devel xsp nant wget tar sqlite unzip sudo postgresql-server git libsodium || exit -1

repoowner=tpokorra
branch=somebranch
repoowner=openpetra
branch=master
wget https://github.com/$repoowner/openpetra/archive/$branch.tar.gz
tar xzf $branch.tar.gz
cd openpetra-$branch

generatedData=https://github.com/openpetra/demo-databases/archive/master.tar.gz
wget $generatedData -O demodata.tar.gz
tar xzf demodata.tar.gz

mkdir -p demodata/generated
mv demo-databases-master/generatedDataUsedForDemodatabases/*.csv demodata/generated
rm -Rf demo-databases-master

# apply a patch so that starting and stopping works on Linux and Mono
patch -p1 < ../OpenPetra.default.targets.xml.patch || exit -1

# on Fedora 24, there is libsodium.so.18
for f in inc/template/etc/*.config
do
  sed -i "s/libsodium.so.13/libsodium.so.18/g" $f
done

postgresql-setup --initdb --unit postgresql || exit -1
PGHBAFILE=/var/lib/pgsql/data/pg_hba.conf
echo "local all petraserver md5
host all petraserver ::1/128 md5
host all petraserver 127.0.0.1/32 md5" | cat - $PGHBAFILE > /tmp/out && mv -f /tmp/out $PGHBAFILE
/sbin/restorecon -v /var/lib/pgsql/data/pg_hba.conf
systemctl start postgresql
systemctl enable postgresql
# avoid error during createDatabaseUser: sudo: sorry, you must have a tty to run sudo
sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers

# workaround for Fedora 24
export LANG=C

nant generateSolution initConfigFiles || exit -1
nant createDatabaseUser recreateDatabase || exit -1

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

#upload to Github
if [ -f ~/.ssh/gitkey ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/gitkey
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  git clone --depth 1 git@github.com:openpetra/demo-databases.git || exit -1

  alias cp=cp
  cp -f base.yml.gz demo-databases
  cp -f demo*.yml.gz demo-databases
  cd demo-databases
  msg="commit latest demo databases `date +%Y%m%d`"
  git config --global user.name "LBS BuildBot"
  git config --global user.email "buildbot@lbs.solidcharity.com"
  git commit -a -m "$msg" || exit -1
  git push || exit -1
  kill $SSH_AGENT_PID
fi

