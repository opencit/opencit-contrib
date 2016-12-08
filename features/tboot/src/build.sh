#!/bin/bash
TBOOT_VERSION="1.9.4"
TBOOT="tboot-${TBOOT_VERSION}"


yum_detect() {
  yum=`which yum 2>/dev/null`
  if [ -n "$yum" ]; then return 0; else return 1; fi
}

aptget_detect() {
  aptget=`which apt-get 2>/dev/null`
  aptcache=`which apt-cache 2>/dev/null`
  if [ -n "$aptget" ]; then return 0; else return 1; fi
}

generate_binary() {
  # RHEL
  if yum_detect; then
    yum -y install rpmbuild
    if [ $? -ne 0 ]; then echo "Failed to install prerequisites through package installer"; return 1; fi
    rpmbuild -bb "rpm/tboot.spec" --define "_sourcedir $PWD" --define "_rpmdir $PWD" --nodeps
    tboot_rpm=$(find . -name ${TBOOT}*.rpm)
    classifier=$(echo "${tboot_rpm}" | awk -F'/' '{print $2}')
    mvn install:install-file -Dfile="${tboot_rpm}" -DgroupId=net.sourceforge.tboot -DartifactId=tboot -Dversion="${TBOOT_VERSION}" -Dpackaging=rpm -Dclassifier="${classifier}"
    return
  # UBUNTU
  elif aptget_detect; then
    apt-get -y install packaging-dev debhelper libtspi-dev
    if [ $? -ne 0 ]; then echo "Failed to install prerequisites through package installer"; return 1; fi
    TBOOT_TGZ=$(find . -name ${TBOOT}*-sources.tgz)
    tar fxz "${TBOOT_TGZ}"
    mv debian "${TBOOT}"
    (cd "${TBOOT}" && debuild -b -uc -us)
    tboot_deb=$(find . -name tboot*.deb)
    classifier=$(echo "${tboot_deb%.*}" | awk -F'_' '{print $3}')
    mvn install:install-file -Dfile="${tboot_deb}" -DgroupId="net.sourceforge.tboot" -DartifactId="tboot" -Dversion="${TBOOT_VERSION}" -Dpackaging="deb" -Dclassifier="${classifier}"
    return
  fi
  return 2
}

generate_binary
if [ $? -ne 0 ]; then echo "Failed to generate tboot binary"; exit 2; fi
