#!/bin/bash
MAVEN_REPOSITORY_PATH=${MAVEN_REPOSITORY_PATH:-"~/.m2/repository"}

OPENSSL_VERSION="1.0.2a"
OPENSSL="openssl-${OPENSSL_VERSION}"
OPENSSL_URL="http://openssl.org/source/${OPENSSL}.tar.gz"

TROUSERS_VERSION="0.3.13"
TROUSERS="trousers-${TROUSERS_VERSION}"
TROUSERS_URL="http://downloads.sourceforge.net/project/trousers/trousers/${TROUSERS_VERSION}/${TROUSERS}.tar.gz"

TPM_QUOTE_TOOLS_VERSION="1.0.2"
TPM_QUOTE_TOOLS="tpm-quote-tools-${TPM_QUOTE_TOOLS_VERSION}"
TPM_QUOTE_TOOLS_URL="http://downloads.sourceforge.net/project/tpmquotetools/${TPM_QUOTE_TOOLS_VERSION}/${TPM_QUOTE_TOOLS}.tar.gz"

TPM_TOOLS_VERSION="1.3.8"
TPM_TOOLS="tpm-tools-${TPM_TOOLS_VERSION}"
TPM_TOOLS_URL="http://downloads.sourceforge.net/project/trousers/tpm-tools/${TPM_TOOLS_VERSION}/${TPM_TOOLS}.tar.gz"

TBOOT_VERSION="1.9.4"
TBOOT="tboot-${TBOOT_VERSION}"
TBOOT_URL="http://downloads.sourceforge.net/project/tboot/tboot/${TBOOT}.tar.gz"


yum_detect() {
  yum=`which yum 2>/dev/null`
  if [ -n "$yum" ]; then return 0; else return 1; fi
}

aptget_detect() {
  aptget=`which apt-get 2>/dev/null`
  aptcache=`which apt-cache 2>/dev/null`
  if [ -n "$aptget" ]; then return 0; else return 1; fi
}

download_prerequisites() {
  # RHEL
  if yum_detect; then
    sudo yum -y install wget
    if [ $? -ne 0 ]; then echo "Failed to install prerequisites through package installer"; return 1; fi
    return
  # UBUNTU
  elif aptget_detect; then
    sudo apt-get -y install wget
    if [ $? -ne 0 ]; then echo "Failed to install prerequisites through package installer"; return 1; fi
    return
  fi
  return 2
}

maven_install() {
  local file_name="${1}"
  local group_id="${2}"
  local artifact_id="${3}"
  local version="${4}"
  local packaging="${5}"
  local classifier="${6}"
  mvn install:install-file -Dfile="${file_name}" -DgroupId="${group_id}" -DartifactId="${artifact_id}" -Dversion="${version}" -Dpackaging="${packaging}" -Dclassifier="${classifier}"
}

download_openssl() {
  if [ ! -f "${OPENSSL}.tar.gz" ]; then
    wget --no-check-certificate "${OPENSSL_URL}"
  fi
}
maven_install_openssl() {
  maven_install "${OPENSSL}.tar.gz" "org.openssl" "openssl" "${OPENSSL_VERSION}" "tgz" "sources"
}
download_and_maven_install_openssl() {
  if [ ! -f "${MAVEN_REPOSITORY_PATH}/org/openssl/openssl/${OPENSSL_VERSION}/${OPENSSL}*.tgz" ]; then
    download_openssl
    maven_install_openssl
  fi
}

download_trousers() {
  if [ ! -f "${TROUSERS}.tar.gz" ]; then
    wget --no-check-certificate "${TROUSERS_URL}"
  fi
}
maven_install_trousers() {
  maven_install "${TROUSERS}.tar.gz" "net.sourceforge.trousers" "trousers" "${TROUSERS_VERSION}" "tgz" "sources"
}
download_and_maven_install_trousers() {
  if [ ! -f "${MAVEN_REPOSITORY_PATH}/net/sourceforge/trousers/trousers/${TROUSERS_VERSION}/${TROUSERS}*.tgz" ]; then
    download_trousers
    maven_install_trousers
  fi
}

download_tpm_quote_tools() {
  if [ ! -f "${TPM_QUOTE_TOOLS}.tar.gz" ]; then
    wget --no-check-certificate "${TPM_QUOTE_TOOLS_URL}"
  fi
}
maven_install_tpm_quote_tools() {
  maven_install "${TPM_QUOTE_TOOLS}.tar.gz" "net.sourceforge.tpmquotetools" "tpm-quote-tools" "${TPM_QUOTE_TOOLS_VERSION}" "tgz" "sources"
}
download_and_maven_install_tpm_quote_tools() {
  if [ ! -f "${MAVEN_REPOSITORY_PATH}/net/sourceforge/tpmquotetools/tpm-quote-tools/${TPM_QUOTE_TOOLS_VERSION}/${TPM_QUOTE_TOOLS}*.tgz" ]; then
    download_tpm_quote_tools
    maven_install_tpm_quote_tools
  fi
}

download_tpm_tools() {
  if [ ! -f "${TPM_TOOLS}.tar.gz" ]; then
    wget --no-check-certificate "${TPM_TOOLS_URL}"
  fi
}
maven_install_tpm_tools() {
  maven_install "${TPM_TOOLS}.tar.gz" "net.sourceforge.trousers" "tpm-tools" "${TPM_TOOLS_VERSION}" "tgz" "sources"
}
download_and_maven_install_tpm_tools() {
  if [ ! -f "${MAVEN_REPOSITORY_PATH}/net/sourceforge/trousers/tpm-tools/${TPM_TOOLS_VERSION}/${TPM_TOOLS}*.tgz" ]; then
    download_tpm_tools
    maven_install_tpm_tools
  fi
}

download_tboot() {
  if [ ! -f "${TBOOT}.tar.gz" ]; then
    wget --no-check-certificate "${TBOOT_URL}"
  fi
}
maven_install_tboot() {
  maven_install "${TBOOT}.tar.gz" "net.sourceforge.tboot" "tboot" "${TBOOT_VERSION}" "tgz" "sources"
}
download_and_maven_install_tboot() {
  if [ ! -f "${MAVEN_REPOSITORY_PATH}/net/sourceforge/tboot/tboot/${TBOOT_VERSION}/${TBOOT}*.tgz" ]; then
    download_tboot
    maven_install_tboot
  fi
}


echo "Downloading and installing prerequisites..."
download_prerequisites
if [ $? -ne 0 ]; then echo "Failed to install prerequisites through package manager"; exit 1; fi
echo "Downloading and maven installing openssl..."
download_and_maven_install_openssl
if [ $? -ne 0 ]; then echo "Failed to download and maven install openssl"; exit 2; fi
echo "Downloading and maven installing trousers..."
download_and_maven_install_trousers
if [ $? -ne 0 ]; then echo "Failed to download and maven install trousers"; exit 3; fi
echo "Downloading and maven installing TPM quote tools..."
download_and_maven_install_tpm_quote_tools
if [ $? -ne 0 ]; then echo "Failed to download and maven install TPM quote tools"; exit 4; fi
echo "Downloading and maven installing TPM tools..."
download_and_maven_install_tpm_tools
if [ $? -ne 0 ]; then echo "Failed to download and maven install TPM tools"; exit 5; fi
echo "Downloading and maven installing tboot..."
download_and_maven_install_tboot
if [ $? -ne 0 ]; then echo "Failed to download and maven install tboot"; exit 6; fi
