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
OP_CUSTOMER=$user /home/$user/openpetra-server.sh loadYmlGz $demodbfile || exit -1

nant checkHtml || exit -1

cd js-client
# improve speed of initial request by user by forcing to load all assemblies now
curl --silent --retry 5 http://localhost/api/serverSessionManager.asmx/IsUserLoggedIn # > /dev/null
LANG=en CYPRESS_baseUrl=http://localhost ./node_modules/.bin/cypress run --config video=false || exit -1
# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo
