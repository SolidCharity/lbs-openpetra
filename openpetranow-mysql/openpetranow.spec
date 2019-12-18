%define name %{PKGNAME}
%define version %{VERSION}
%define branch %{BRANCH}
%define OpenPetraServerPath /home/openpetra
# for CentOS7
%define LIBSODIUM_VERSION 23
%define debug_package %{nil}

Summary: Server of OpenPetra using MySQL as database backend
Name: %{name}
Version: %{version}
Release: %{release}
Packager: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
License: GPL
Group: Office Suite and Productivity
AutoReqProv: no
BuildRequires: libsodium
Requires: mono-core >= 5.10 mono-data mono-mvc mono-wcf mono-winfx xsp mariadb-server nginx lsb libsodium
Requires: liberation-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts liberation-serif-fonts liberation-sans-fonts
BuildRoot: /tmp/buildroot
Source:  openpetra-bin.tar.gz

%description
OpenPetra is a Free Administration Software for Non-Profits
and developed as an open-source project under GPL licence.
This package provides the server running with MySQL as database backend.

%prep
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT
%setup -q -n openpetra-%{version}.0

%build

# branding of packages
sed -i 's~<title>OpenPetra</title>~<title>OpenPetra by SolidCharity</title>~g' client/index.html

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{OpenPetraServerPath}
cp -R `pwd`/* $RPM_BUILD_ROOT/%{OpenPetraServerPath}
rm -f $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/Mono.Security.dll
rm -f $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/Mono.Data.Sqlite.dll
rm -f $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/sqlite3.dll
rm -f $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/libsodium.dll
rm -f $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/libsodium-64.dll
ln -s %{_libdir}/libsodium.so.%{LIBSODIUM_VERSION} $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin/libsodium.so
dos2unix $RPM_BUILD_ROOT/%{OpenPetraServerPath}/openpetra-server.sh
mkdir -p $RPM_BUILD_ROOT/usr/lib/systemd/system
cat `pwd`/templates/openpetra.service \
	| sed -e "s#OPENPETRA_SERVER_BIN#${OpenPetraServerPath}/openpetra-server.sh#" \
	| sed -e "s#OPENPETRA_USER#openpetra#" \
	> $RPM_BUILD_ROOT/usr/lib/systemd/system/openpetra.service
mv $RPM_BUILD_ROOT/%{OpenPetraServerPath}/templates/common.config $RPM_BUILD_ROOT/%{OpenPetraServerPath}/etc/common.config

%post
adduser --no-create-home openpetra
chmod a+r -R %{OpenPetraServerPath}
chown -R openpetra:openpetra %{OpenPetraServerPath}
systemctl enable openpetra
systemctl start openpetra

%clean
# Clean up after ourselves, but be careful in case someone sets a bad buildroot
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT

%files
%{OpenPetraServerPath}
/usr/lib/systemd/system

%changelog
* Sat Dec 14 2019 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- use binary tarball as source
* Sat Aug 10 2019 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- include Bootstrap 4.0 because wkhtmltopdf does not format grids with newer Bootstrap
* Mon Aug 05 2019 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- js-client is now part of the main tarball
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
