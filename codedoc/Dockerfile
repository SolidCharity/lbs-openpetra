# get the key for the Xamarin packages
RUN rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
# get the key for the OpenPetra packages
RUN rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0x4796B710919684AC"
RUN dnf -y install tar createrepo gcc rpm-build rpm-sign gnupg make curl rsync 'dnf-command(config-manager)'
RUN dnf -y install mono-core mono-devel libgdiplus-devel nant wget tar sqlite doxygen openssh-clients

