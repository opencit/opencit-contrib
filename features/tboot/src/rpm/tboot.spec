Summary:        Performs a verified launch using Intel TXT
Name:           tboot
Version:        1.9.4
Release:        2%{?dist}
Epoch:          1

Group:          System Environment/Base
License:        BSD
URL:            http://sourceforge.net/projects/tboot/
Source0:        http://downloads.sourceforge.net/%{name}/%{name}-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  trousers-devel
BuildRequires:  openssl-devel
ExclusiveArch:  x86_64

%description
Trusted Boot (tboot) is an open source, pre-kernel/VMM module that uses
Intel Trusted Execution Technology (Intel TXT) to perform a measured
and verified launch of an OS kernel/VMM.

%prep
%setup -q

%build
TROUSERS=${TROUSERS:-/opt/mtwilson/share/trousers}; export TROUSERS
CFLAGS="$RPM_OPT_FLAGS -I$TROUSERS/include"; export CFLAGS
LDFLAGS="-L$OPENSSL/lib -L$TROUSERS/lib"; export LDFLAGS
make debug=y %{?_smp_mflags}

# If this is a UEFI system, warn user that tboot is not supported and
# provide links to the advisories.
#
%pre
if [ -e "/sys/firmware/efi" ]; then
	putk() { echo -e "$1" | tee /dev/kmsg; }
	putk "WARNING: tboot is not supported on UEFI-based systems."
	putk "         Please see https://access.redhat.com/articles/2217041."
	putk "         and https://access.redhat.com/articles/2464721"
	exit 0;
fi

%install
rm -rf $RPM_BUILD_ROOT
make debug=y DISTDIR=$RPM_BUILD_ROOT install

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc README COPYING docs/* lcptools/lcptools2.txt lcptools/Linux_LCP_Tools_User_Manual.pdf
%config %{_sysconfdir}/grub.d/20_linux_tboot
%config %{_sysconfdir}/grub.d/20_linux_xen_tboot
%{_sbindir}/acminfo
%{_sbindir}/lcp_crtpconf
%{_sbindir}/lcp_crtpol
%{_sbindir}/lcp_crtpol2
%{_sbindir}/lcp_crtpolelt
%{_sbindir}/lcp_crtpollist
%{_sbindir}/lcp_mlehash
%{_sbindir}/lcp_readpol
%{_sbindir}/lcp_writepol
%{_sbindir}/lcp2_crtpol
%{_sbindir}/lcp2_crtpolelt
%{_sbindir}/lcp2_crtpollist
%{_sbindir}/lcp2_mlehash
%{_sbindir}/parse_err
%{_sbindir}/tb_polgen
%{_sbindir}/tpmnv_defindex
%{_sbindir}/tpmnv_getcap
%{_sbindir}/tpmnv_lock
%{_sbindir}/tpmnv_relindex
%{_sbindir}/txt-stat
%{_mandir}/man8/acminfo.8.gz
%{_mandir}/man8/lcp_crtpconf.8.gz
%{_mandir}/man8/lcp_crtpol.8.gz
%{_mandir}/man8/lcp_crtpol2.8.gz
%{_mandir}/man8/lcp_crtpolelt.8.gz
%{_mandir}/man8/lcp_crtpollist.8.gz
%{_mandir}/man8/lcp_mlehash.8.gz
%{_mandir}/man8/lcp_readpol.8.gz
%{_mandir}/man8/lcp_writepol.8.gz
%{_mandir}/man8/tb_polgen.8.gz
%{_mandir}/man8/txt-stat.8.gz
/boot/tboot.gz
/boot/tboot-syms

%changelog
* Tue Aug 09 2016 Tony Camuso <tcamuso@redhat.com> - 1:1.9.4-2
- Test for UEFI system with /sys/firmware/efi, rather than looking in
  the boot directory for an efi directory.
- Allow install on UEFI platform, but with warning message, in order to
  permit completion of provisioning.
  Resolves: rhbz#1356571

* Thu May 19 2016 Tony Camuso <tcamuso@redhat.com> - 1:1.9.4-1
- Upgrade 1.9.4 release
- Fixed bad day-of-week of first entry in changelog
- Do not install on systems with efi partition
  See https://access.redhat.com/articles/2217041
  Resolves: rhbz#1275031
  Resolves: rhbz#1293526
  Resolves: rhbz#1307176
  Resolves: rhbz#1313876
  Resolves: rhbz#1332691

* Tue Oct 07 2014 Tony Camuso <tcamuso@redhat.com> - 1:1.8.2-1
- Upgrade to tboot 1.8.2
  Resolves: rhbz#1147070

* Tue Jan 21 2014 David Cantrell <dcantrell@redhat.com> - 1:1.7.4-1
- Upgrade to tboot 1.7.4 to fix S3, S4, and S5
  Resolves: rhbz#1046872

* Wed Jan 08 2014 David Cantrell <dcantrell@redhat.com> - 1:1.7.3-5
- Restrict package to x86_64
  Resolves: rhbz#1048903

* Fri Dec 27 2013 Daniel Mach <dmach@redhat.com> - 1:1.7.3-4
- Mass rebuild 2013-12-27

* Tue Apr 02 2013 Gang Wei <gang.wei@intel.com> - 1:1.7.3-3
- Fix for breaking grub2-mkconfig operation in 32bit case(#929384)

* Wed Feb 20 2013 Gang Wei <gang.wei@intel.com> - 1:1.7.3-2
- Fix version string in log

* Wed Jan 30 2013 David Cantrell <dcantrell@redhat.com> - 1:1.7.3-1
- Upgrade to latest upstream version (#902653)

* Wed Aug 22 2012 Gang Wei <gang.wei@intel.com> - 1:1.7.0-2
- Fix build error with zlib 1.2.7

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1:1.7.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Sun Jan 15 2012 Gang Wei <gang.wei@intel.com> - 1:1.7.0
- 1.7.0 release

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 20110429-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Fri Apr 29 2011 Gang Wei <gang.wei@intel.com> - 20110429-1
- Pull upstream changeset 255, rebuilt in F15

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 20101005-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Wed Dec 1 2010 Joseph Cihula <joseph.cihula@intel.com> - 20101005-1.fc13
- Initial import
