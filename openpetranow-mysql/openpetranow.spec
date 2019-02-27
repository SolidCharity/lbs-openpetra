%define name %{PKGNAME}
%define version %{VERSION}
%define branch %{BRANCH}
%define MonoPath /usr/
%define OpenPetraServerPath /usr/local/openpetra
# for CentOS7
%define LIBSODIUM_VERSION 23
%define debug_package %{nil}

Summary: Server of OpenPetra using MySQL as database backend
Name: %{name}
Version: %{version}
Release: %{release}
Packager: Timotheus Pokorra <tp@tbits.net>
License: GPL
Group: Office Suite and Productivity
AutoReqProv: no
BuildRequires: nant dos2unix gettext mono-mvc mono-wcf mono-devel >= 5.10 mono-data liberation-mono-fonts libgdiplus-devel
BuildRequires: nodejs >= 8.9.4
Requires: mono-core >= 5.10 mono-data mono-mvc mono-wcf mono-winfx xsp mariadb-server nginx lsb libsodium
Requires: liberation-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts liberation-serif-fonts liberation-sans-fonts
BuildRoot: /tmp/buildroot
Source:  sources.tar.gz
Source1: sources-client.tar.gz
Source2: i18n.tar.gz
Source3: base.yml.gz
Source4: clean.yml.gz

%description
OpenPetra is a Free Administration Software for Non-Profits
and developed as an open-source project under GPL licence.
This package provides the server running with MySQL as database backend.

%prep
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT
%setup  -q -n openpetra-%{branch}
tar xzf %{SOURCE1}
mv openpetra-client-js-%{branch} ../openpetra-client
# i18n.tar.gz
tar xzf %{SOURCE2}
mv openpetra-i18n-master/i18n/de.po i18n/de_DE.po
mv openpetra-i18n-master/i18n/es.po i18n/es_ES.po
mv openpetra-i18n-master/i18n/da.po i18n/da_DK.po

%build
nant buildRPM -D:ReleaseID=%{version}.%{release} \
    -D:LinuxTargetDistribution-list=centos-mysql \
    -D:DBMS.Type=mysql

# branding of packages
sed -i 's~<title>OpenPetra</title>~<title>OpenPetra by SolidCharity</title>~g' ../openpetra-client/index.html

# make sure the user gets the latest javascript and html specific to this build
sed -i 's~CURRENTRELEASE~%{version}.%{release}~g' ../openpetra-client/src/lib/navigation.js
sed -i 's~CURRENTRELEASE~%{version}.%{release}~g' ../openpetra-client/src/lib/i18n.js
sed -i 's~CURRENTRELEASE~%{version}.%{release}~g' ../openpetra-client/index.html
sed -i "s/develop = 1;/develop = 0;/g" ../openpetra-client/src/lib/navigation.js
sed -i "s/debug = 1;/debug = 0;/g" ../openpetra-client/src/lib/navigation.js
sed -i "s/develop = 1;/develop = 0;/g" ../openpetra-client/src/lib/i18n.js
sed -i "s/develop = 1;/develop = 0;/g" ../openpetra-client/index.html

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{OpenPetraServerPath}
cp -R `pwd`/delivery/bin/tmp/openpetraorg-%{version}.%{release}/* $RPM_BUILD_ROOT/%{OpenPetraServerPath}
cd $RPM_BUILD_ROOT/%{OpenPetraServerPath}/server && ln -s ../bin bin && cd -
cd $RPM_BUILD_ROOT/%{OpenPetraServerPath}/server && ln -s . api && cd -
(cd ../openpetra-client && npm install && npm run build && \
 cp node_modules/bootstrap/dist/css/bootstrap.min.css css && \
 rm -Rf node_modules && cd - ) || exit -1
cp -R ../openpetra-client/* $RPM_BUILD_ROOT/%{OpenPetraServerPath}/client
mkdir -p $RPM_BUILD_ROOT/usr/bin
chmod a+x $RPM_BUILD_ROOT/%{OpenPetraServerPath}/openpetra-server.sh
dos2unix $RPM_BUILD_ROOT/%{OpenPetraServerPath}/openpetra-server.sh
cd $RPM_BUILD_ROOT/usr/bin && ln -s ../../%{OpenPetraServerPath}/openpetra-server.sh openpetra-server && cd -
cd $RPM_BUILD_ROOT/%{OpenPetraServerPath}/server && mv ../etc/web-sample.config web.config && cd -
# base.yml.gz
cp %{SOURCE3} $RPM_BUILD_ROOT/%{OpenPetraServerPath}/db
# clean.yml.gz
cp %{SOURCE4} $RPM_BUILD_ROOT/%{OpenPetraServerPath}/db
mkdir -p $RPM_BUILD_ROOT/usr/lib/systemd/system
cp `pwd`/setup/petra0300/linuxserver/mysql/centos/openpetra-server.service $RPM_BUILD_ROOT/usr/lib/systemd/system/openpetra.service
rm -f $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/libsodium*.dll
ln -s %{_libdir}/libsodium.so.%{LIBSODIUM_VERSION} $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/libsodium.so

%clean
# Clean up after ourselves, but be careful in case someone sets a bad buildroot
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT

%files
%{OpenPetraServerPath}
/usr/lib/systemd/system
/usr/bin/openpetra-server

%changelog
* Tue Feb 27 2018 Timotheus Pokorra <tp@tbits.net>
- use npm to manage javascript libraries and to bundle them
* Mon Dec 04 2017 Timotheus Pokorra <tp@tbits.net>
- prepare release with javascript client
* Fri Feb 03 2017 Timotheus Pokorra <tp@tbits.net>
- prepare release 2016-12
* Mon Oct 03 2016 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- prepare release 2016-07
* Wed Sep 02 2015 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- prepare release 2015-09
* Thu Jun 25 2015 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- prepare release 2015-06
* Tue Feb 17 2015 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- build for CentOS7 and with Xamarin packages
* Sat Jan 31 2015 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- release 2015-01
* Mon Nov 17 2014 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- release 2014-11
* Wed Jul 30 2014 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- release 2014-07
* Sat May 31 2014 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- release 2014-05
* Thu Aug 01 2013 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- build from github
* Thu Jul 04 2013 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- First build
