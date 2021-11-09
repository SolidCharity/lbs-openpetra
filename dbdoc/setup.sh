#!/bin/bash

# get our own mono packages
apt-get -y install apt-transport-https dirmngr gnupg ca-certificates
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x4796B710919684AC
echo 'deb [arch=amd64] https://download.solidcharity.com/repos/tpokorra/mono/debian/buster buster main' | tee /etc/apt/sources.list.d/mono-tpokorra.list
echo 'deb [arch=amd64] https://download.solidcharity.com/repos/tpokorra/nant/debian/buster buster main' >> /etc/apt/sources.list
echo 'deb [arch=amd64] https://download.solidcharity.com/repos/solidcharity/openpetra/debian/buster buster main' >> /etc/apt/sources.list
apt-get update

apt-get -y install nant mono-devel mono-xsp4 mono-fastcgi-server4 ca-certificates-mono xfonts-75dpi fonts-liberation libgdiplus sql2diagram || exit -1

# to avoid errors like: error CS0433: The imported type `System.CodeDom.Compiler.CompilerError' is defined multiple times
if [ -f /usr/lib/mono/4.5-api/System.dll -a -f /usr/lib/mono/4.5/System.dll ]; then
  rm -f /usr/lib/mono/4.5-api/System.dll
fi

wget https://github.com/openpetra/openpetra/archive/master.tar.gz
tar xzf master.tar.gz
cd openpetra-master

cat > OpenPetra.build.config << EOF
<?xml version="1.0"?>
<project name="OpenPetra-userconfig">
    <property name="DBMS.Type" value="sqlite"/>
    <property name="DBMS.Password" value=""/>
    <property name="sql2dia" value="sql2dia" overwrite="false"/>
</project>
EOF

nant generateTools dbdoc || exit -1
# need to run twice, so that the diagrams can be picked up
nant dbdoc || exit -1

cd delivery/dbdoc
rm -Rf bak
rm -Rf *.bat
cd ..

#upload to Hostsharing
if [ -f ~/.ssh/id_rsa_cronjob ]
then
  rsync -avz --delete -e "ssh -o 'StrictHostKeyChecking no' -i ~/.ssh/id_rsa_cronjob" dbdoc tim00-openpetra@tim00.hostsharing.net:.
fi

