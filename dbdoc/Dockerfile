# get our own mono packages
RUN apt-get -y install apt-transport-https dirmngr gnupg ca-certificates
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0x4796B710919684AC
RUN echo 'deb [arch=amd64] https://lbs.solidcharity.com/repos/tpokorra/mono/debian/buster buster main' | tee /etc/apt/sources.list.d/mono-tpokorra.list
RUN echo 'deb [arch=amd64] https://lbs.solidcharity.com/repos/tpokorra/nant/debian/buster buster main' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install nant mono-devel mono-xsp4 mono-fastcgi-server4 ca-certificates-mono xfonts-75dpi fonts-liberation libgdiplus

