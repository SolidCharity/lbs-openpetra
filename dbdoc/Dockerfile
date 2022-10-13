# get our own mono packages
RUN apt-get -y install apt-transport-https dirmngr gnupg ca-certificates
RUN mkdir /root/.gnupg
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/tpokorra-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x4796B710919684AC
RUN echo 'deb [arch=amd64, signed-by=/usr/share/keyrings/tpokorra-keyring.gpg] https://download.solidcharity.com/repos/tpokorra/mono/debian/buster buster main' | tee /etc/apt/sources.list.d/tpokorra-mono.list
RUN echo 'deb [arch=amd64, signed-by=/usr/share/keyrings/tpokorra-keyring.gpg] https://download.solidcharity.com/repos/tpokorra/nant/debian/buster buster main' | tee  /etc/apt/sources.list.d/tpokorra-nant.list

RUN apt-get update
RUN apt-get -y install nant mono-devel mono-xsp4 mono-fastcgi-server4 ca-certificates-mono xfonts-75dpi fonts-liberation libgdiplus sql2diagram

