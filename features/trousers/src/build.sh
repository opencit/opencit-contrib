#!/bin/bash
TROUSERS_VERSION="0.3.13"
TROUSERS="trousers-${TROUSERS_VERSION}"

export PREFIX="${OPENSSL:-/opt/mtwilson/share/trousers}"
export OPENSSL="${OPENSSL:-/opt/mtwilson/share/openssl}"
export LINUX_TARGET="${LINUX_TARGET:-generic}"
export CFLAGS="-fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security"
export LDFLAGS="-z noexecstack -z relro -z now -pie"


install_trousers() {
  mkdir -p $PREFIX/include
  mkdir -p $PREFIX/lib
  TROUSERS_FILE=`find ${TROUSERS}*gz`
  echo "trousers: $TROUSERS_FILE"
  if [ -n "$TROUSERS_FILE" ] && [ -f "$TROUSERS_FILE" ]; then
    rm -rf $TROUSERS
    tar fxz $TROUSERS_FILE
    #(cd $TROUSERS && ./configure --prefix=$PREFIX --with-openssl=$PREFIX/ssl && make && make install)
    #--enable-cross-compile
    # specifying --with-openssl=$PREFIX is important here in order to be able to compile tpm-tools later;
    # if we don't specify it then we will get errors like this when compiling tpm-tools:
    #    /opt/dcgcontrib/lib/libtspi.so: undefined reference to `EVP_EncryptUpdate@OPENSSL_1.0.0'
    # re: std=gnu89, see: https://sourceforge.net/p/trousers/mailman/message/31262347/
    (cd $TROUSERS && patch -p1 < ../trousers.patch)
    if [ $? -ne 0 ]; then echo "Failed to patch trousers"; exit 1; fi
    (cd $TROUSERS && CFLAGS="${CFLAGS} -std=gnu89" LDFLAGS="${LDFLAGS}" ./configure --prefix=$PREFIX --with-openssl=$OPENSSL)
    if [ $? -ne 0 ]; then echo "Failed to configure trousers"; exit 2; fi
    (cd $TROUSERS && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" ${KWFLAGS_TROUSERS} make)
    if [ $? -ne 0 ]; then echo "Failed to make trousers"; exit 3; fi
    (cd $TROUSERS && CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" make install)
    if [ $? -ne 0 ]; then echo "Failed to make install trousers"; exit 4; fi
    #if [ -d /etc/ld.so.conf.d ]; then
      #echo $PREFIX/lib > /etc/ld.so.conf.d/trousers.conf
    #fi
    #ldconfig
  fi
}

# look for /usr/sbin/tcsd, return 0 if found, return 1 if not found
detect_trousers() {
  trousers_bin=`which tcsd`
  if [ -n "$trousers_bin" ]; then return 0; fi
  return 1
}

install_trousers
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean