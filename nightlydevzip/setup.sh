#!/bin/bash

# get the key for the Xamarin packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
yum -y install mono xsp nant wget tar sqlite

wget https://github.com/openpetra/openpetra/archive/master.tar.gz || exit -1
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

nant devzip || exit -1

#upload to Sourceforge
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  echo "put ../openpetra_development_`date +"%Y-%m-%d"`.zip" | sftp -o StrictHostKeyChecking=no pokorra@frs.sourceforge.net:/home/frs/project/openpetraorg/openpetraorg/devzip-nightly || exit -1
  rm -f ../openpetra_development_`date +"%Y-%m-%d" --date='10 days ago'`.zip
  echo "rm openpetra_development_`date +"%Y-%m-%d" --date='10 days ago'`.zip" | sftp -o StrictHostKeyChecking=no pokorra@frs.sourceforge.net:/home/frs/project/openpetraorg/openpetraorg/devzip-nightly || exit -1
  kill $SSH_AGENT_PID
fi

mv ../openpetra_development_`date +"%Y-%m-%d"`.zip ~/tarball
rm -f ~/tarball/openpetra_development_`date +"%Y-%m-%d" --date='6 days ago'`.zip
echo download at https://download.solidcharity.com/tarballs/tpokorra/openpetra/openpetra_development_`date +"%Y-%m-%d"`.zip
