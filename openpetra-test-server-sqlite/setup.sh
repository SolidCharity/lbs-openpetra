#!/bin/bash

db_tag=UsedForNUnitTests
user=op_dev
dbms=mysql
branch=master
if [ ! -z "$1" ]; then
  branch=$1
fi
ghubuser=openpetra
if [ ! -z "$2" ]; then
  ghubuser=$2
fi

curl https://getopenpetra.com | bash -s devenv $ghubuser $branch $dbms || exit -1

cd /home/$user/openpetra

# need this for the tests
curl --silent --location https://github.com/openpetra/demo-databases/raw/$db_tag/demoWith1ledger.yml.gz > demoWith1ledger.yml.gz || exit -1

nant test-without-display || exit -1

nant checkHtml || exit -1
nant checkCode || exit -1
