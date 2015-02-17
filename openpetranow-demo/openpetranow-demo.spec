%define name openpetranow-demo
%define version 2015.01.0
%define trunkversion 20150131_fixdemo
%define MonoPath /usr/
%define OpenPetraServerPath /usr/local/openpetraorg

Summary: server of OpenPetra using Postgresql as database backend
Name: %{name}
Version: %{version}
Release: %{release}
Packager: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
License: GPL
Group: Office Suite and Productivity
AutoReqProv: no
BuildRequires: nant dos2unix nsis gettext
Requires: mono xsp postgresql-server >= 9.2 lighttpd lighttpd-fastcgi lsb
BuildRoot: /tmp/buildroot
Source: %{trunkversion}.tar.gz
Source1: base.yml.gz
Source2: plugin_bankimport.tar.gz
Source3: plugin_bankimport_csv.tar.gz
Source4: plugin_bankimport_mt940.tar.gz
Patch1: setup_withremoteclient.patch
Patch2: setup_remote_client.patch
Patch3: NoChangePasswordDemo.patch
Patch4: fix_postglbatch_postingregister.patch
Patch5: fix_uploadymlgz.patch
Patch6: fixClientDownload.patch

%description
Server of OpenPetra using Postgresql as database backend

%prep
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT
%setup  -q -n openpetra-%{trunkversion}
dos2unix setup/setup.build
%patch1 -p1
dos2unix js/Default.aspx
%patch2 -p1
dos2unix csharp/ICT/Petra/Server/lib/MSysMan/UserManager.cs
%patch3 -p1
dos2unix csharp/ICT/Petra/Server/lib/MFinance/Common/Common.Posting.cs
%patch4 -p1
dos2unix csharp/ICT/Common/IO/Yml2Xml.cs
%patch5 -p1
dos2unix js/Client.aspx
%patch6 -p1
tar xzf ../../SOURCES/plugin_bankimport.tar.gz && mv OpenPetraPlugin_Bankimport-master csharp/ICT/Petra/Plugins/Bankimport
tar xzf ../../SOURCES/plugin_bankimport_csv.tar.gz && mv OpenPetraPlugin_BankimportCSV-master csharp/ICT/Petra/Plugins/BankimportCSV
tar xzf ../../SOURCES/plugin_bankimport_mt940.tar.gz && mv OpenPetraPlugin_BankimportMT940-master csharp/ICT/Petra/Plugins/BankimportMT940

%build
# TODO initdb
#nant nanttasks createDatabaseUser
export NSISDIR=/usr/local/nsis/
export PATH=$NSISDIR:$PATH
nant buildServerCentOSPostgresqlOBS -D:ReleaseID=%{version}.%{release}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{OpenPetraServerPath}
cp -R `pwd`/delivery/bin/tmp/openpetraorg-%{version}.%{release}/* $RPM_BUILD_ROOT/%{OpenPetraServerPath}
mkdir -p $RPM_BUILD_ROOT/%{OpenPetraServerPath}/client
cp `pwd`/delivery/*.exe $RPM_BUILD_ROOT/%{OpenPetraServerPath}/client
cp `pwd`/delivery/Patch-win_%{version}.0_%{version}.%{release}.zip $RPM_BUILD_ROOT/%{OpenPetraServerPath}/client
mkdir -p $RPM_BUILD_ROOT/var/www
ln -s ../../%{OpenPetraServerPath}/asmx $RPM_BUILD_ROOT/var/www/openpetra
ln -s ../bin30 $RPM_BUILD_ROOT/%{OpenPetraServerPath}/asmx/bin
ln -s ../client $RPM_BUILD_ROOT/%{OpenPetraServerPath}/asmx/client
mv $RPM_BUILD_ROOT/%{OpenPetraServerPath}/js30/Client.aspx $RPM_BUILD_ROOT/%{OpenPetraServerPath}/client/Default.aspx
cd $RPM_BUILD_ROOT/%{OpenPetraServerPath}/asmx; ln -s ../js30/* .; cd -
mv $RPM_BUILD_ROOT/%{OpenPetraServerPath}/openpetraorg-server.sh $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin30/openpetra-server
chmod a+x $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin30/openpetra-server
dos2unix $RPM_BUILD_ROOT/%{OpenPetraServerPath}/bin30/openpetra-server
# allow the OpenPetra server to copy the installer files for each customer
chmod a+w $RPM_BUILD_ROOT/%{OpenPetraServerPath}/client/
cp ../../SOURCES/base.yml.gz $RPM_BUILD_ROOT/%{OpenPetraServerPath}/db30
mkdir -p $RPM_BUILD_ROOT/usr/lib/systemd/system
cp `pwd`/setup/petra0300/linuxserver/postgresql/centos/openpetra-server.service $RPM_BUILD_ROOT/usr/lib/systemd/system

%clean
# Clean up after ourselves, but be careful in case someone sets a bad buildroot
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT

%files
%{OpenPetraServerPath}
/usr/lib/systemd/system
/var/www/openpetra

%post
echo "For the first install, now run:"
echo "  %{OpenPetraServerPath}/bin30/openpetra-server init"

%changelog
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
