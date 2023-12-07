#!/bin/bash

apt-get install -y make git rsync python3-pip || exit -1
# don't use graphviz yet
# pip3 install sphinx || exit -1
apt-get install -y python3-sphinx || exit -1


cd ~

if [ ! -d docs-en ]
then
  git clone --depth 1 https://github.com/openpetra/openpetra-docs.git docs-en
  git clone --depth 1 https://github.com/openpetra/openpetra-docs-de.git docs-de
fi

#export PATH=/usr/libexec/python3-sphinx:$PATH
cd ~/docs-en
make html || exit -1
cd ~/docs-de
make html || exit -1
cd ~

#upload to Hostsharing
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  rsync -avz --delete -e "ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/id_rsa_cronjob" docs-en/build/html tim00-openpetra@tim00.hostsharing.net:manual-en || exit -1
  rsync -avz --delete -e "ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/id_rsa_cronjob" docs-de/build/html tim00-openpetra@tim00.hostsharing.net:manual-de || exit -1
else
  echo "Upload of docs is not configured"
  exit -1
fi
