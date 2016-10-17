#!/bin/bash

# prereqs: openssl, trousers
export PREFIX=${PREFIX:-/opt/mtwilson/share/openssl}
export LINUX_TARGET=${LINUX_TARGET:-generic}

TROUSERS_OPENSSL_TPM_ENGINE_URL=http://downloads.sourceforge.net/project/trousers/OpenSSL%20TPM%20Engine/0.4.2/openssl_tpm_engine-0.4.2.tar.gz

OPENSSL_TPM_ENGINE=openssl-tpm-engine-0.4.2
# when extracting the .tgz file, it creates this directory name with underscores instead of hyphens
OPENSSL_TPM_ENGINE_DIR=openssl_tpm_engine-0.4.2

download_files() {
  if [ ! -f $OPENSSL_TPM_ENGINE.tar.gz ]; then
    wget $TROUSERS_OPENSSL_TPM_ENGINE_URL
    mvn install:install-file -Dfile=openssl_tpm_engine-0.4.2.tar.gz -DgroupId=net.sourceforge.trousers -DartifactId=openssl-tpm-engine -Dversion=0.4.2 -Dpackaging=tgz -Dclassifier=sources
  fi
}

install_openssl_tpm_engine() {
  mkdir -p $PREFIX
  OPENSSL_TPM_ENGINE_FILE=`find ${OPENSSL_TPM_ENGINE}*gz`
  echo "openssl-tpm-engine: $OPENSSL_TPM_ENGINE_FILE"
  if [ -n "$OPENSSL_TPM_ENGINE_FILE" ] && [ -f "$OPENSSL_TPM_ENGINE_FILE" ]; then
    rm -rf $OPENSSL_TPM_ENGINE_DIR
    tar fxz $OPENSSL_TPM_ENGINE_FILE
    #(cd $OPENSSL_TPM_ENGINE && LDFLAGS="-L$PREFIX/lib" ./configure --with-openssl=$PREFIX/ssl && make && make install)
	#(cd $OPENSSL_TPM_ENGINE && LDFLAGS="-L$PREFIX/lib" ./configure --prefix=$PREFIX --with-openssl=$PREFIX && make && make install)
	(cd $OPENSSL_TPM_ENGINE_DIR && ./configure --prefix=$PREFIX --with-openssl=$PREFIX && make && make install)
    #if [ -d /etc/ld.so.conf.d ]; then
    #  echo $PREFIX/lib/openssl/engines > /etc/ld.so.conf.d/openssl-engines.conf
    #fi
    #ldconfig
    #export LD_LIBRARY_PATH=$PREFIX/lib/openssl/engines
  fi
}

install_openssl_tpm_engine
