#!/bin/bash

yum install -y wget mono-nant-opt
wget http://bazaar.launchpad.net/~christian-k/openpetraorg/20140624_webservices_branch__client_server_fixes/tarball/2588  || exit -1

tar xzf 2588 || exit -1
cd \~christian-k/openpetraorg/20140624_webservices_branch__client_server_fixes/

. /opt/mono/env.sh
nant generateSolution || exit -1
nant regenerateDatabase resetDatabase || exit -1
nant test-without-display || exit -1
