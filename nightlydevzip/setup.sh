#!/bin/bash

yum -y install mono-xsp-opt mono-opt-devel mono-nant-opt wget tar sqlite
. /opt/mono/env.sh

wget https://github.com/openpetra/openpetra/archive/master.tar.gz
tar xzf master.tar.gz
mv openpetra-master nightlydevzip

cd nightlydevzip
cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
</project>
EOF

nant devzip

#upload to Sourceforge
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  echo "put ../openpetra_development_`date +"%Y-%m-%d"`.zip" | sftp -o StrictHostKeyChecking=no pokorra@frs.sourceforge.net:/home/frs/project/openpetraorg/openpetraorg/devzip-nightly
  rm -f ../openpetra_development_`date +"%Y-%m-%d" --date='10 days ago'`.zip
  echo "rm openpetra_development_`date +"%Y-%m-%d" --date='10 days ago'`.zip" | sftp -o StrictHostKeyChecking=no pokorra@frs.sourceforge.net:/home/frs/project/openpetraorg/openpetraorg/devzip-nightly
  kill $SSH_AGENT_PID
fi

mv ../openpetra_development_`date +"%Y-%m-%d"`.zip ~/tarball
rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d --date='6 days ago'"`.zip
echo download at http://download.lbs.solidcharity.com/tarballs/tpokorra/openpetra/openpetra_development_`date +"%Y-%m-%d"`.zip
