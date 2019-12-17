#!/bin/bash

user=op_test
url=test.localhost

curl https://getopenpetra.com | bash -s test --instance=$user --url=$url || exit -1

curl http://localhost > index.out
if [[ -z "`cat index.out | grep reqnewpwdclickhere`" ]]; then
  exit -1
fi

curl http://localhost/api/serverSessionManager.asmx/IsUserLoggedIn? > isuserloggedin.out
expected='"resultcode":"error"'
if [[ -z "`cat isuserloggedin.out | grep $expected`" ]]; then
  exit -1
fi

# we need a line feed so that the 0 is on the last line on its own for LBS to know that this succeeded
echo
