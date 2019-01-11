#!/bin/bash

dnf install -y make python3-sphinx git rsync || exit -1
# don't use graphviz yet

cd ~

if [ ! -d docs-en ]
then
  git clone --depth 1 https://github.com/openpetra/openpetra-docs.git docs-en
  git clone --depth 1 https://github.com/openpetra/openpetra-docs-de.git docs-de
fi

export PATH=/usr/libexec/python3-sphinx:$PATH
cd ~/docs-en
export LANG=C
make html || exit -1
cd ~/docs-de
export LANG="de_DE.UTF-8"
make html || exit -1
cd ~

#upload to Hostsharing
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  rsync -avz --delete -e "ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/id_rsa_cronjob" docs-en/build/html tim00-openpetra@tim00.hostsharing.net:manual-en
  rsync -avz --delete -e "ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/id_rsa_cronjob" docs-de/build/html tim00-openpetra@tim00.hostsharing.net:manual-de
fi
