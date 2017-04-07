#!/bin/bash
TPM_QUOTE_TOOLS_VERSION="1.0.2"
TPM_QUOTE_TOOLS="tpm-quote-tools-${TPM_QUOTE_TOOLS_VERSION}"

export PREFIX=${PREFIX:-/opt/mtwilson/share/tpmquote}
export OPENSSL=${OPENSSL:-/opt/mtwilson/share/openssl}
export TROUSERS=${TROUSERS:-/opt/mtwilson/share/trousers}
export LINUX_TARGET=${LINUX_TARGET:-generic}
export CFLAGS="-fstack-protector-strong -fPIE -fPIC -O2 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security"
export LDFLAGS="-z noexecstack -z relro -z now -pie"


install_tpm_quote_tools() {
  mkdir -p $PREFIX
  TPM_QUOTE_TOOLS_FILE=`find ${TPM_QUOTE_TOOLS}*gz`
  echo "tpm-quote-tools: $TPM_QUOTE_TOOLS_FILE"
  if [ -n "$TPM_QUOTE_TOOLS_FILE" ] && [ -f "$TPM_QUOTE_TOOLS_FILE" ]; then
    rm -rf $TPM_QUOTE_TOOLS
    tar fxz $TPM_QUOTE_TOOLS_FILE
    (cd $TPM_QUOTE_TOOLS && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" ./configure --prefix=$PREFIX)
    if [ $? -ne 0 ]; then echo "Failed to configure TPM quote tools"; exit 1; fi
    (cd $TPM_QUOTE_TOOLS && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" PREFIX=$PREFIX make)
    if [ $? -ne 0 ]; then echo "Failed to make TPM quote tools"; exit 2; fi
    (cd $TPM_QUOTE_TOOLS && CFLAGS="${CFLAGS} -I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="${LDFLAGS} -L$OPENSSL/lib -L$TROUSERS/lib" PREFIX=$PREFIX make install)
    if [ $? -ne 0 ]; then echo "Failed to make install TPM quote tools"; exit 3; fi
  fi
}

install_tpm_quote_tools
rm -rf dist-clean
mkdir dist-clean
cp -r $PREFIX dist-clean
