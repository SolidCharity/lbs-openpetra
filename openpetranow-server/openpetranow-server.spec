%define name openpetranow-server
%define version 2014.5.1
%define trunkversion Release2014_05
%define MonoPath /opt/mono
%define OpenPetraServerPath /usr/local/openpetraorg

Summary: server of OpenPetra using Postgresql as database backend
Name: %{name}
Version: %{version}
Release: 1
Packager: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
License: GPL
Group: Office Suite and Productivity
BuildRequires: mono-nant-opt dos2unix
Requires: mono-xsp-opt mono-opt postgresql-server = 9.2 lighttpd lighttpd-fastcgi lsb
BuildRoot: /tmp/buildroot
Source: %{trunkversion}.tar.gz
Source1: base.yml.gz
Patch0: optmono.patch

%description
Server of OpenPetra using Postgresql as database backend

%prep
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT
%setup  -q -n OpenPetraNow-%{trunkversion}
%patch0 -p1

%build
. %{MonoPath}/env.sh
# TODO initdb
#nant nanttasks createDatabaseUser
nant buildServerCentOSPostgresqlOBS -D:ReleaseID=%{version}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{OpenPetraServerPath}
cp -R `pwd`/delivery/bin/tmp/openpetraorg-%{version}/* $RPM_BUILD_ROOT/%{OpenPetraServerPath}
mkdir -p $RPM_BUILD_ROOT/var/www
ln -s ../../%{OpenPetraServerPath}/asmx $RPM_BUILD_ROOT/var/www/openpetra
ln -s ../bin30 $RPM_BUILD_ROOT/%{OpenPetraServerPath}/asmx/bin
mkdir -p $RPM_BUILD_ROOT/etc/init.d
mv $RPM_BUILD_ROOT/%{OpenPetraServerPath}/openpetraorg-server.sh $RPM_BUILD_ROOT/etc/init.d/openpetra-server
chmod a+x $RPM_BUILD_ROOT/etc/init.d/openpetra-server
dos2unix $RPM_BUILD_ROOT/etc/init.d/openpetra-server
cp ../../SOURCES/base.yml.gz $RPM_BUILD_ROOT/%{OpenPetraServerPath}/db30

%clean
# Clean up after ourselves, but be careful in case someone sets a bad buildroot
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT

%files
%{OpenPetraServerPath}
/etc/init.d/openpetra-server
/var/www/openpetra

%post
echo "For the first install, now run:"
echo "  service openpetra-server init"
echo "  service openpetra-server start"

%changelog
* Sat May 31 2014 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- release 2014-05
* Thu Aug 01 2013 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- build from github
* Sat Jul 04 2013 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- First build
