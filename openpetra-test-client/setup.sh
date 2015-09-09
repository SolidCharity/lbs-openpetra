#!/bin/bash

yum install -y epel
#install the key from Xamarin
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
yum install -y wget sudo mono mono-mvc mono-wcf nant xsp postgresql-server lsb
yum install -y xorg-x11-server-Xvfb patch
wget https://github.com/openpetra/openpetra/archive/master.tar.gz || exit -1

tar xzf master.tar.gz || exit -1
cd openpetra-master

postgresql-setup initdb
PGHBAFILE=/var/lib/pgsql/data/pg_hba.conf
echo "local all petraserver md5
host all petraserver ::1/128 md5
host all petraserver 127.0.0.1/32 md5" | cat - $PGHBAFILE > /tmp/out && mv -f /tmp/out $PGHBAFILE
systemctl start postgresql
systemctl enable postgresql

# avoid error during createDatabaseUser: sudo: sorry, you must have a tty to run sudo
sed -i "s/Defaults    requiretty/#Defaults    requiretty/g" /etc/sudoers

nant generateTools || exit -1
nant generateORM || exit -1
nant createDatabaseUser || exit -1
nant recreateDatabase resetDatabase || exit -1
nant generateSolution || exit -1

/usr/bin/Xvfb :99 -screen 0 1024x768x24 -fbdir /var/run -ac >& /dev/null &
nant test-client || exit -1
