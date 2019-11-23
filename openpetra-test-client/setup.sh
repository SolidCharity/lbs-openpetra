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
demodbfile=demoWith1ledger.yml.gz
curl --silent --location https://github.com/openpetra/demo-databases/raw/$db_tag/demoWith1ledger.yml.gz > $demodbfile || exit -1
OP_CUSTOMER=$user /home/$user/openpetra-server.sh loadYmlGz $demodbfile || exit -1

nant checkHtml || exit -1

nant test-client || exit -1

# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo
