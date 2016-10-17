#!/bin/bash
export PREFIX=${PREFIX:-/opt/mtwilson/share/openssl}
export LINUX_TARGET=${LINUX_TARGET:-generic}
OPENSSL_URL=http://openssl.org/source/openssl-1.0.2a.tar.gz
OPENSSL=openssl-1.0.2a

download_files() {
  if [ ! -f $OPENSSL.tar.gz ]; then
    wget $OPENSSL_URL
    mvn install:install-file -Dfile=openssl-1.0.2a.tar.gz -DgroupId=org.openssl -DartifactId=openssl -Dversion=1.0.2a -Dpackaging=tgz -Dclassifier=sources
  fi
}

install_openssl() {
  mkdir -p $PREFIX
  OPENSSL_FILE=`find ${OPENSSL}*gz`
  echo "openssl: $OPENSSL_FILE"
  if [ -n "$OPENSSL_FILE" ] && [ -f "$OPENSSL_FILE" ]; then
    rm -rf $OPENSSL
    tar fxz $OPENSSL_FILE
	# options "no-idea no-mdc2 no-rc5" disable support for these patented algorithms
	# --enable-cross-compile
    (cd $OPENSSL && ./config --shared --prefix=$PREFIX --openssldir=$PREFIX no-idea no-mdc2 no-rc5 && make && make install)
    #if [ -d /etc/ld.so.conf.d ]; then
      #echo /usr/local/ssl/lib/ > /etc/ld.so.conf.d/openssl.conf
	  #echo $PREFIX/lib > /etc/ld.so.conf.d/openssl.conf
    #fi
    # Root can use 'ldconfig', so when compiling as non-root, we skip it 
    #ldconfig
  fi
}


# look for /usr/bin/openssl, return 0 if found, return 1 if not found
detect_openssl() {
  openssl_bin=`which openssl`
  if [ -n "$openssl_bin" ]; then return 0; fi
  return 1
}

install_openssl
