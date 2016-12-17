#!/bin/bash

dnf install -y make python3-sphinx git rsync
# don't use graphviz yet

cd ~

if [ ! -d docs-en ]
then
  git clone --depth 1 https://github.com/openpetra/openpetra-docs.git docs-en
  git clone --depth 1 https://github.com/openpetra/openpetra-docs-de.git docs-de
fi

cd ~/docs-en
make html
cd ~/docs-de
make html
cd ~

#upload to Hostsharing
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  rsync -avz --delete -i ~/.ssh/id_rsa_cronjob docs-en/build/html tim00-openpetra@tim00.hostsharing.net:manual-en
  rsync -avz --delete -i ~/.ssh/id_rsa_cronjob docs-de/build/html tim00-openpetra@tim00.hostsharing.net:manual-de
fi
