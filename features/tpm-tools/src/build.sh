#!/bin/bash
export PREFIX=${PREFIX:-${HOME:-/tmp}/local}
export LINUX_TARGET=${LINUX_TARGET:-generic}
TPM_TOOLS_URL=http://downloads.sourceforge.net/project/trousers/tpm-tools/1.3.8/tpm-tools-1.3.8.tar.gz
TPM_TOOLS=tpm-tools-1.3.8

download_files() {
  if [ ! -f $TPM_TOOLS.tar.gz ]; then
    wget $TPM_TOOLS_URL
    mvn install:install-file -Dfile=tpm-tools-1.3.8.tar.gz -DgroupId=net.sourceforge.trousers -DartifactId=tpm-tools -Dversion=1.3.8 -Dpackaging=tgz -Dclassifier=sources
  fi
}

install_tpm_tools() {
  mkdir -p $PREFIX
  TPM_TOOLS_FILE=`find ${TPM_TOOLS}*gz`
  echo "tpm-tools: $TPM_TOOLS_FILE"
  if [ -n "$TPM_TOOLS_FILE" ] && [ -f "$TPM_TOOLS_FILE" ]; then
    rm -rf $TPM_TOOLS
    tar fxz $TPM_TOOLS_FILE
    patch $TPM_TOOLS/src/tpm_mgmt/tpm_nvread.c 1.3.8/tpm-tools-1.3.8_src_tpm_nvread.patch
	# note: /usr/local/ssl directory specified in our openssl build script
    #(cd $TPM_TOOLS && LDFLAGS="-L/usr/local/lib -L/usr/local/ssl/lib" CFLAGS="-I/usr/local/ssl/include"  ./configure --prefix=/usr/local && make && make install)
	# LD_PRELOAD="/opt/dcgcontrib/lib/libcrypto.so.1.0.0" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" 
	(cd $TPM_TOOLS && CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" ./configure --prefix=$PREFIX --with-openssl=$PREFIX && make && make install)
  fi
}

install_tpm_tools_contrib() {
  #what it was before using PREFIX:  gcc -g -O0 -DLOCALEDIR='"/usr/share/locale"' -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_createkey tpm_createkey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 

  #gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -I$PREFIX/include -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_createkey tpm_createkey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  #gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -I$PREFIX/include -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_bindaeskey tpm_bindaeskey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c -lcrypto -ltspi 
  #gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -I$PREFIX/include -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_unbindaeskey tpm_unbindaeskey.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  #gcc -g -O0 -L$PREFIX/lib -DLOCALEDIR='"/usr/share/locale"' -I$PREFIX/include -Itpm-tools-1.3.8 -Itpm-tools-1.3.8/include -o tpm_signdata  tpm_signdata.c tpm-tools-1.3.8/lib/tpm_tspi.c tpm-tools-1.3.8/lib/tpm_utils.c tpm-tools-1.3.8/lib/tpm_log.c hex2bytea.c -lcrypto -ltspi 
  #mkdir -p $PREFIX/bin
  #cp tpm_createkey tpm_bindaeskey tpm_unbindaeskey tpm_signdata $PREFIX/bin
  ( cd 1.3.8 && CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" TPM_TOOLS_SRC="../tpm-tools-1.3.8" make && make install )
}


# look for /usr/sbin/tpm_version, return 0 if found, 1 if not found
detect_tpm_tools() {
  tpm_tools_bin=`which tpm_version`
  if [ -n "$tpm_tools_bin" ]; then return 0; fi
  return 1
}

install_tpm_tools && install_tpm_tools_contrib
