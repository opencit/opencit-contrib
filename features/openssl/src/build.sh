#!/bin/bash
OPENSSL_VERSION="1.0.2a"
OPENSSL="openssl-${OPENSSL_VERSION}"

export PREFIX="${PREFIX:-/opt/mtwilson/share/openssl}"
export LINUX_TARGET="${LINUX_TARGET:-generic}"
export CFLAGS="-fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security"
export LDFLAGS="-z noexecstack -z relro -z now -pie"


install_openssl() {
  mkdir -p $PREFIX
  OPENSSL_FILE=`find ${OPENSSL}*gz`
  echo "openssl: $OPENSSL_FILE"
  if [ -n "$OPENSSL_FILE" ] && [ -f "$OPENSSL_FILE" ]; then
    rm -rf $OPENSSL
    tar fxz $OPENSSL_FILE
    (cd $OPENSSL && patch -p1 <../version-script.patch)
    if [ $? -ne 0 ]; then echo "Failed to patch openssl with version information"; exit 9; fi
    # options "no-idea no-mdc2 no-rc5" disable support for these patented algorithms
    # --enable-cross-compile
    (cd $OPENSSL && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" ./config --shared --prefix=$PREFIX --openssldir=$PREFIX no-idea no-mdc2 no-rc5)
    if [ $? -ne 0 ]; then echo "Failed to configure openssl"; exit 1; fi
    (cd $OPENSSL && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" make)
    if [ $? -ne 0 ]; then echo "Failed to make openssl"; exit 2; fi
    (cd $OPENSSL && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" make install)
    if [ $? -ne 0 ]; then echo "Failed to make install openssl"; exit 3; fi
    if [ -d /etc/ld.so.conf.d ]; then
      echo $PREFIX/lib | sudo -n tee /etc/ld.so.conf.d/openssl.conf
    fi
    sudo -n ldconfig
  fi
}

# look for /usr/bin/openssl, return 0 if found, return 1 if not found
detect_openssl() {
  openssl_bin=`which openssl`
  if [ -n "$openssl_bin" ]; then return 0; fi
  return 1
}

install_openssl
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean