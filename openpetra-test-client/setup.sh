#!/bin/bash

db_tag=UsedForNUnitTests
branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi
ghubuser=openpetra
if [ ! -z "$2" ]; then
  ghubuser=$2
fi

yum install -y epel
yum install -y wget sudo mono-devel mono-data mono-mvc mono-winfxcore mono-wcf libgdiplus-devel nant NUnit xsp lsb libsodium \
  mariadb-server \
  libXScrnSaver GConf2 Xvfb gtk3 \
  liberation-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts liberation-serif-fonts liberation-sans-fonts \
  || exit -1

wget https://github.com/Holger-Will/code-128-font/raw/master/fonts/code128.ttf -O /usr/share/fonts/code128.ttf

curl --silent --location https://rpm.nodesource.com/setup_8.x  | bash -
yum -y install nodejs
#node --version
#8.9.4
#npm --version
#5.6.0

npm set progress=false
npm install -g browserify --quiet
npm install -g uglify-es --quiet

# avoid error during createDatabaseUser: sudo: sorry, you must have a tty to run sudo
sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers

yum-config-manager --disable lbs-solidcharity-openpetra
yum-config-manager --add-repo https://lbs.solidcharity.com/repos/solidcharity/openpetra/centos/7/lbs-solidcharity-openpetra.repo
yum install -y openpetranow-mysql-test
export OPENPETRA_DBPWD=`openpetra-server generatepwd`
openpetra-server init || exit -1
openpetra-server initdb || exit -1
file=/tmp/demoWith1ledger.yml.gz
wget --no-verbose https://github.com/openpetra/demo-databases/raw/$db_tag/demoWith1ledger.yml.gz -O $file || exit -1
/usr/bin/openpetra-server loadYmlGz $file || exit -1
/usr/bin/openpetra-server upgradedb || exit -1

# on Fedora 24, there is libsodium.so.18, on CentOS7 there is libsodium.so.23
cd /usr/lib64
if [ -f libsodium.so.18 ]
then
  ln -s libsodium.so.18 libsodium.so
elif [ -f libsodium.so.13 ]
then
  ln -s libsodium.so.13 libsodium.so
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

wget --no-verbose https://github.com/$ghubuser/openpetra/archive/$branch.tar.gz -O sources.tar.gz || exit -1

tar xzf sources.tar.gz || exit -1
openpetradir=$(find . -type d -name openpetra-*)

cd $openpetradir

cat > OpenPetra.build.config <<FINISH
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="mysql"/>
    <property name="DBMS.RootPassword" value=""/>
</project>
FINISH

nant generateSolution || exit -1

# need to install the node_modules so that nant install.js will work
cd js-client
# set CI=1 to avoid too much output from installing cypress. see https://github.com/cypress-io/cypress/issues/1243#issuecomment-365560861
( CI=1 npm install --quiet && npm run build ) || exit -1
cd -

nant install || exit -1
sleep 3
systemctl status openpetra

nant checkHtml

cd js-client
# improve speed of initial request by user by forcing to load all assemblies now
curl --silent --retry 5 http://localhost/api/serverSessionManager.asmx/IsUserLoggedIn # > /dev/null
LANG=en CYPRESS_baseUrl=http://localhost ./node_modules/.bin/cypress run --config video=false || exit -1
# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo
