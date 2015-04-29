#!/bin/bash
PREFIX=${PREFIX:-/opt/dcgcontrib}
TROUSERS_URL=http://downloads.sourceforge.net/project/trousers/trousers/0.3.13/trousers-0.3.13.tar.gz
TROUSERS=trousers-0.3.13

download_files() {
  if [ ! -f $TROUSERS.tar.gz ]; then
    wget $TROUSERS_URL
  fi
}

install_trousers() {
  mkdir -p $PREFIX
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
	(cd $TROUSERS && ./configure --prefix=$PREFIX --with-openssl=$PREFIX && make && make install)
    #if [ -d /etc/ld.so.conf.d ]; then
      #echo $PREFIX/lib > /etc/ld.so.conf.d/trousers.conf
    #fi
    ldconfig
  fi
}

# look for /usr/sbin/tcsd, return 0 if found, return 1 if not found
detect_trousers() {
  trousers_bin=`which tcsd`
  if [ -n "$trousers_bin" ]; then return 0; fi
  return 1
}

( cd 0.3.13 && download_files && install_trousers )
