Name: cookethflow
Version: 0.1.0
Release: 1%{?dist}
Summary: A visual thinking tool.
Group: Application/Emulator
Vendor: Cooketh Company
Packager: Subroto Banerjee <subroto.2003@gmail.com>
License: MIT
URL: https://github.com/CookethOrg/Cooketh-Flow
BuildArch: x86_64

%description
A new Flutter project.

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/%{name}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/metainfo
mkdir -p %{buildroot}%{_datadir}/pixmaps
cp -r %{name}/* %{buildroot}%{_datadir}/%{name}
ln -s %{_datadir}/%{name}/%{name} %{buildroot}%{_bindir}/%{name}
cp -r %{name}.desktop %{buildroot}%{_datadir}/applications
cp -r %{name}.png %{buildroot}%{_datadir}/pixmaps
cp -r %{name}*.xml %{buildroot}%{_datadir}/metainfo || :
update-mime-database %{_datadir}/mime &> /dev/null || :

%postun
update-mime-database %{_datadir}/mime &> /dev/null || :

%files
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/metainfo


%defattr(-,root,root)

%attr(4755, root, root) %{_datadir}/pixmaps/%{name}.png
