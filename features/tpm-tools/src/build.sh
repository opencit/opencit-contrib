#!/bin/bash
TPM_TOOLS_VERSION="1.3.8"
TPM_TOOLS="tpm-tools-${TPM_TOOLS_VERSION}"

export PREFIX=${PREFIX:-/opt/mtwilson/share/tpmtools}
export OPENSSL=${OPENSSL:-/opt/mtwilson/share/openssl}
export TROUSERS=${TROUSERS:-/opt/mtwilson/share/trousers}
export LINUX_TARGET=${LINUX_TARGET:-generic}
export CFLAGS="-fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security"
export LDFLAGS="-z noexecstack -z relro -z now -pie"


install_tpm_tools() {
  mkdir -p $PREFIX
  TPM_TOOLS_FILE=`find ${TPM_TOOLS}*gz`
  echo "tpm-tools: $TPM_TOOLS_FILE"
  if [ -n "$TPM_TOOLS_FILE" ] && [ -f "$TPM_TOOLS_FILE" ]; then
    rm -rf $TPM_TOOLS $TPM_TOOLS-patched
    tar fxz $TPM_TOOLS_FILE
    \cp -r $TPM_TOOLS ${TPM_TOOLS}-patched
    \cp -r 1.3.8/modified/. ${TPM_TOOLS}-patched
    chmod 755 $TPM_TOOLS/configure
    chmod 755 $TPM_TOOLS-patched/configure
    diff -ur $TPM_TOOLS $TPM_TOOLS-patched > $TPM_TOOLS.patch
    
    # note: /usr/local/ssl directory specified in our openssl build script
    #(cd $TPM_TOOLS && LDFLAGS="-L/usr/local/lib -L/usr/local/ssl/lib" CFLAGS="-I/usr/local/ssl/include"  ./configure --prefix=/usr/local && make && make install)
    # LD_PRELOAD="/opt/dcgcontrib/lib/libcrypto.so.1.0.0" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" 
    (cd $TPM_TOOLS-patched && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" ./configure --prefix=$PREFIX --with-openssl=$OPENSSL)
    if [ $? -ne 0 ]; then echo "Failed to configure TPM tools"; exit 1; fi
    (cd $TPM_TOOLS-patched && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" ${KWFLAGS_TPM_TOOLS} make)
    if [ $? -ne 0 ]; then echo "Failed to make TPM tools"; exit 2; fi
    (cd $TPM_TOOLS-patched && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" make install)
    if [ $? -ne 0 ]; then echo "Failed to make install TPM tools"; exit 3; fi
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
  (cd "1.3.8/additions" && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" TPM_TOOLS_SRC="../../tpm-tools-1.3.8-patched" ${KWFLAGS_TPM_TOOLS_ADDITIONS} make)
  if [ $? -ne 0 ]; then echo "Failed to make TPM tools contributions"; exit 4; fi
  (cd "1.3.8/additions" && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" TPM_TOOLS_SRC="../../tpm-tools-1.3.8-patched" PREFIX=$PREFIX make install)
  if [ $? -ne 0 ]; then echo "Failed to make install TPM tools contributions"; exit 5; fi
}

# look for /usr/sbin/tpm_version, return 0 if found, 1 if not found
detect_tpm_tools() {
  tpm_tools_bin=`which tpm_version`
  if [ -n "$tpm_tools_bin" ]; then return 0; fi
  return 1
}

install_tpm_tools && install_tpm_tools_contrib
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean

