#!/bin/bash

PGVERSION=9.2

rpm -Uhv http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm
rpm -Uhv http://mirror.de.leaseweb.net/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum install -y wget mono-nant-opt postgresql92-server sudo
wget http://bazaar.launchpad.net/~christian-k/openpetraorg/20140624_webservices_branch__client_server_fixes/tarball/2588  || exit -1

tar xzf 2588 || exit -1
cd \~christian-k/openpetraorg/20140624_webservices_branch__client_server_fixes/

. /opt/mono/env.sh
ln -s /opt/mono /opt/mono-openpetra

PATH=/usr/pgsql-$PGVERSION/bin:$PATH
ln -s /usr/pgsql-9.2/bin/psql /usr/bin/psql
service postgresql-$PGVERSION initdb
PGHBAFILE=/var/lib/pgsql/$PGVERSION/data/pg_hba.conf
echo "local all petraserver md5
host all petraserver ::1/128 md5
host all petraserver 127.0.0.1/32 md5" | cat - $PGHBAFILE > /tmp/out && mv -f /tmp/out $PGHBAFILE
service postgresql-$PGVERSION start

nant generateTools
nant createDatabaseUser
nant recreateDatabase resetDatabase || exit -1
nant generateSolution || exit -1
nant test-without-display || exit -1
