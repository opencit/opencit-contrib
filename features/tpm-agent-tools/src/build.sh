#!/bin/bash
export PREFIX=${PREFIX:-/opt/mtwilson/share/tpmquote}
export OPENSSL=${OPENSSL:-/opt/mtwilson/share/openssl}
export TROUSERS=${TROUSERS:-/opt/mtwilson/share/trousers}
export LINUX_TARGET=${LINUX_TARGET:-generic}


install_tpm_agent_tools() {
  #gcc -I$PREFIX/include -L$PREFIX/lib -o aikquote aikquote.c -ltspi
  #gcc -I$PREFIX/include -L$PREFIX/lib -o aikqverify aikqverify.c -ltspi -lcrypto
  #gcc -I$PREFIX/include -L$PREFIX/lib -o getcert getcert.c -ltspi
  #gcc -I$PREFIX/include -L$PREFIX/lib -o getcert01 getcert01.c -ltspi
  #mkdir -p $PREFIX
  #cp aikquote aikqverify getcert getcert01 $PREFIX/bin
  (CFLAGS="-I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="-L$OPENSSL/lib -L$TROUSERS/lib" ${KWFLAGS_TPM_AGENT_TOOLS} make)
  if [ $? -ne 0 ]; then echo "Failed to make TPM agent tools"; exit 1; fi
  (PREFIX=$PREFIX make install)
  if [ $? -ne 0 ]; then echo "Failed to make install TPM agent tools"; exit 2; fi
}

install_tpm_agent_tools
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean
