%define name sql2diagram
%define version 0.2
%define DATE    %(date +%%Y%%m%%d)

Summary: create html documentation for sql database structure
Name: %{name}
Version: %{version}
Release: %{release}
Packager: Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
License: GPL
Group: Development
Requires: libxml2
BuildRequires: gcc libtool automake gcc-c++ libxml2-devel
Source: sql2diagram.tar.gz

%description
create html documentation for sql database structure

%prep
[ -d $RPM_BUILD_ROOT ] && [ "/" != "$RPM_BUILD_ROOT" ] && rm -rf $RPM_BUILD_ROOT
%setup -q -n sql2diagram-master

%build
aclocal
autoconf
automake --add-missing
./configure
make

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/bin/
cp src/sql2dia %{buildroot}/usr/bin/

%clean
# Clean up after ourselves, but be careful in case someone sets a bad buildroot
[ -d %{buildroot} ] && [ "/" != "%{buildroot}" ] && rm -rf %{buildroot}

%files
/usr/bin/sql2dia

%post

%changelog
* Mon Jun 17 2013 Timotheus Pokorra <timotheus.pokorra@solidcharity.com>
- First build

