#!/bin/bash

user=op_test
url="http://test.localhost"

curl https://getopenpetra.com | bash -s test --instance=$user --url=$url || exit -1

sleep 5

curl --silent --location http://localhost > index.out
if [[ -z "`cat index.out | grep reqnewpwdclickhere`" ]]; then
  echo "cannot find reqnewpwdclickhere"
  exit -1
fi

curl --silent --location http://localhost/api/serverSessionManager.asmx/IsUserLoggedIn? > isuserloggedin.out
expected='"resultcode":"error"'
if [[ -z "`cat isuserloggedin.out | grep $expected`" ]]; then
  echo "cannot find resultcode error"
  cat isuserloggedin.out
  exit -1
fi

# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo
