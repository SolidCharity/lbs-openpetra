#!/bin/bash

branch="master"
if [ ! -z "$1" ]; then
  branch=$1
fi

test=0
if [[ $branch =~ .*test ]]
then
  test=1
fi

# drop repositories that are installed by the docker image
# they become activated by yum-builddep, and then the mirrors might not work
rm -Rf /etc/yum.repos.d/CentOS-Sources.repo /etc/yum.repos.de/CentOS-Vault.repo

yum install -y wget unzip

wget https://get.openpetra.org/openpetra-latest-bin.tar.gz -O openpetra-bin.tar.gz || exit -1

version=`tar xzf openpetra-bin.tar.gz --wildcards "*/pkg_version.txt" -O`
major=`echo $version | cut -d. -f1`
minor=`echo $version | cut -d. -f2`
revision=`echo $version | cut -d. -f3`
build=`echo $version | cut -d. -f4`
version="$major.$minor.$revision"
pkgversion="$major.$minor.$revision.$build"

sed -i "s#%{BRANCH}#$branch#g" openpetranow.spec
sed -i "s#%{VERSION}#$version#g" openpetranow.spec
sed -i "s#%{PKGVERSION}#$pkgversion#g" openpetranow.spec

# branding of the package
sed -i "s#%{ORGNAME}#by SolidCharity#g" openpetranow.spec
sed -i "s#%{ORGNAMEWITHOUTSPACE}#SolidCharity#g" openpetranow.spec
sed -i "s#%{PUBLISHERURL}#http://www.solidcharity.com#g" openpetranow.spec
sed -i "s#%{PUBLISHERNAME}#SolidCharity#g" openpetranow.spec

if [ $test -eq 1 ]
then
  mv openpetranow.spec openpetranow-mysql-test.spec
  sed -i "s#%{PKGNAME}#openpetranow-mysql-test#g" openpetranow-mysql-test.spec
else
  mv openpetranow.spec openpetranow-mysql.spec
  sed -i "s#%{PKGNAME}#openpetranow-mysql#g" openpetranow-mysql.spec
fi

