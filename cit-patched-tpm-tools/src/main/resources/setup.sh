#!/bin/bash
#chmod 700 buildTools.sh tpm-tools-1.3.8.patch tpm-tools-1.3.8/configure tpm-tools-1.3.8-patched/configure trousers-0.3.13/configure
#makeself --follow --nocomp . install-patched-tpm-tools.bin install-patched-tpm-tools bash buildTools.sh

echo_success() {
  if [ "$TERM_DISPLAY_MODE" = "color" ]; then echo -en "${TERM_COLOR_GREEN}"; fi
  echo ${@:-"[  OK  ]"}
  if [ "$TERM_DISPLAY_MODE" = "color" ]; then echo -en "${TERM_COLOR_NORMAL}"; fi
  return 0
}
echo_failure() {
  if [ "$TERM_DISPLAY_MODE" = "color" ]; then echo -en "${TERM_COLOR_RED}"; fi
  echo ${@:-"[FAILED]"}
  if [ "$TERM_DISPLAY_MODE" = "color" ]; then echo -en "${TERM_COLOR_NORMAL}"; fi
  return 1
}
echo_warning() {
  if [ "$TERM_DISPLAY_MODE" = "color" ]; then echo -en "${TERM_COLOR_YELLOW}"; fi
  echo ${@:-"[WARNING]"}
  if [ "$TERM_DISPLAY_MODE" = "color" ]; then echo -en "${TERM_COLOR_NORMAL}"; fi
  return 1
}
function getFlavour() {
  flavour=""
  grep -c -i ubuntu /etc/*-release > /dev/null
  if [ $? -eq 0 ] ; then
    flavour="ubuntu"
  fi
  grep -c -i "red hat" /etc/*-release > /dev/null
  if [ $? -eq 0 ] ; then
    flavour="rhel"
  fi
  grep -c -i fedora /etc/*-release > /dev/null
  if [ $? -eq 0 ] ; then
    flavour="fedora"
  fi
  grep -c -i suse /etc/*-release > /dev/null
  if [ $? -eq 0 ] ; then
    flavour="suse"
  fi
  grep -c -i centos /etc/*-release > /dev/null
  if [ $? -eq 0 ]; then
    flavour="centos"
  fi
  if [ "$flavour" == "" ] ; then
    echo "Unsupported linux flavor, Supported versions are ubuntu, rhel, fedora"
    exit
  else
    echo $flavour
  fi
}
yum_detect() {
  yum=`which yum 2>/dev/null`
  if [ -n "$yum" ]; then return 0; else return 1; fi
}
no_yum() {
  if yum_detect; then return 1; else return 0; fi
}
rpm_detect() {
  rpm=`which rpm 2>/dev/null`
}
aptget_detect() {
  aptget=`which apt-get 2>/dev/null`
  aptcache=`which apt-cache 2>/dev/null`
}
dpkg_detect() {
  dpkg=`which dpkg 2>/dev/null`
}
yast_detect() {
  yast=`which yast 2>/dev/null`
}
zypper_detect() {
  zypper=`which zypper 2>/dev/null`
}
trousers_detect() {
  trousers=`which tcsd 2>/dev/null`
}
auto_install() {
  local component=${1}
  local cprefix=${2}
  local yum_packages=$(eval "echo \$${cprefix}_YUM_PACKAGES")
  local apt_packages=$(eval "echo \$${cprefix}_APT_PACKAGES")
  local yast_packages=$(eval "echo \$${cprefix}_YAST_PACKAGES")
  local zypper_packages=$(eval "echo \$${cprefix}_ZYPPER_PACKAGES")
  # detect available package management tools. start with the less likely ones to differentiate.
  yum_detect; yast_detect; zypper_detect; rpm_detect; aptget_detect; dpkg_detect;
  if [[ -n "$zypper" && -n "$zypper_packages" ]]; then
    zypper install $zypper_packages
  elif [[ -n "$yast" && -n "$yast_packages" ]]; then
    yast -i $yast_packages
  elif [[ -n "$yum" && -n "$yum_packages" ]]; then
    yum -y install $yum_packages
  elif [[ -n "$aptget" && -n "$apt_packages" ]]; then
    apt-get -y install $apt_packages
  fi
}

os_flavour=$(getFlavour)
if [ $os_flavour != null ] && [ $os_flavour == "rhel" ]; then
  yum-config-manager --enable rhel-6-server-optional-rpms
fi

TRUSTAGENT_YUM_PACKAGES="make gcc openssl openssl-devel trousers trousers-devel"
TRUSTAGENT_APT_PACKAGES="make gcc openssl libtspi-dev trousers trousers-dbg"
TRUSTAGENT_YAST_PACKAGES="make gcc openssl openssl-devel trousers trousers-devel"
TRUSTAGENT_ZYPPER_PACKAGES="make gcc openssl openssl-devel trousers trousers-devel"
auto_install "Installer requirements" "TRUSTAGENT"
if [ $? -ne 0 ]; then echo_failure "Failed to install prerequisites through package manager"; exit -1; fi

##do openssl
#cd openssl-1.0.1e && ./config --shared && make && make install
#echo /usr/local/ssl/lib > /etc/ld.so.conf.d/openssl.conf
#ldconfig
#cd ..
#do trousers
#cd trousers-0.3.13 && ./configure --prefix=/usr/local --with-openssl=/usr/local/ssl && make && make install
##cd trousers-0.3.13 && ./configure && make && make install
##echo /usr/local/lib > /etc/ld.so.conf.d/trousers.conf
##ldconfig
##cd ..
#do tpm-tools
( cd tpm-tools-1.3.8-patched && chmod +x configure && LDFLAGS="-L/usr/local/lib" ./configure --prefix=/usr/local && make && make install )
