#!/bin/bash
export PREFIX=${OPENSSL:-/opt/mtwilson/share/trousers}
export OPENSSL=${OPENSSL:-/opt/mtwilson/share/openssl}
export LINUX_TARGET=${LINUX_TARGET:-generic}
TROUSERS_URL=http://downloads.sourceforge.net/project/trousers/trousers/0.3.13/trousers-0.3.13.tar.gz
TROUSERS=trousers-0.3.13

download_files() {
  if [ ! -f $TROUSERS.tar.gz ]; then
    wget $TROUSERS_URL
	mvn install:install-file -Dfile=trousers-0.3.13.tar.gz -DgroupId=net.sourceforge.trousers -DartifactId=trousers -Dversion=0.3.13 -Dpackaging=tgz -Dclassifier=sources
  fi
}

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
	#	/opt/dcgcontrib/lib/libtspi.so: undefined reference to `EVP_EncryptUpdate@OPENSSL_1.0.0'
	(cd $TROUSERS && ./configure --prefix=$PREFIX --with-openssl=$OPENSSL && make && make install)
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
