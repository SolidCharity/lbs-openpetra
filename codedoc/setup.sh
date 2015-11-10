#!/bin/bash

# get the key for the Xamarin packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
dnf -y install mono-core mono-devel libgdiplus-devel nant wget tar sqlite doxygen openssh-clients || exit -1

wget https://github.com/openpetra/openpetra/archive/master.tar.gz
#wget https://github.com/tpokorra/openpetra/archive/master.tar.gz
tar xzf master.tar.gz
cd openpetra-master

cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
</project>
EOF

nant quickClean deleteBakFiles minimalGenerateSolution errorCodeDoc apiDoc || exit -1

cd delivery/API-Doc/html
tar czf ../codedoc.tar.gz .

#upload to codedoc.openpetra.org
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  eval `ssh-agent`
  ssh-add ~/.ssh/id_rsa_cronjob
  localmachine=1
  echo "put ../codedoc.tar.gz" | sftp -o StrictHostKeyChecking=no upload@10.0.3.33:codedoc || localmachine=0
  if [ $localmachine = 1 ]
  then
    ssh -o StrictHostKeyChecking=no upload@10.0.3.33 "cd codedoc; tar xzf codedoc.tar.gz" || exit -1
  else
    echo "put ../codedoc.tar.gz" | sftp -o StrictHostKeyChecking=no -oPort=2033 upload@codedoc.openpetra.org:codedoc || exit -1
    ssh -o StrictHostKeyChecking=no -p 2033 upload@codedoc.openpetra.org "cd codedoc; tar xzf codedoc.tar.gz" || exit -1
  fi
  kill $SSH_AGENT_PID
fi

