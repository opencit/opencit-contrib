#!/bin/bash
export PREFIX=${PREFIX:-/opt/mtwilson/share/tpmquote}
export OPENSSL=${OPENSSL:-/opt/mtwilson/share/openssl}
export TROUSERS=${TROUSERS:-/opt/mtwilson/share/trousers}
export LINUX_TARGET=${LINUX_TARGET:-generic}
TPM_QUOTE_TOOLS_URL=http://downloads.sourceforge.net/project/tpmquotetools/1.0.2/tpm-quote-tools-1.0.2.tar.gz
TPM_QUOTE_TOOLS=tpm-quote-tools-1.0.2

download_files() {
  if [ ! -f $TPM_QUOTE_TOOLS.tar.gz ]; then
    wget $TPM_QUOTE_TOOLS_URL
    mvn install:install-file -Dfile=tpm-quote-tools-1.0.2.tar.gz -DgroupId=net.sourceforge.tpmquotetools -DartifactId=tpm-quote-tools -Dversion=1.0.2 -Dpackaging=tgz -Dclassifier=sources
  fi
}

install_tpm_quote_tools() {
  mkdir -p $PREFIX
  TPM_QUOTE_TOOLS_FILE=`find ${TPM_QUOTE_TOOLS}*gz`
  echo "tpm-quote-tools: $TPM_QUOTE_TOOLS_FILE"
  if [ -n "$TPM_QUOTE_TOOLS_FILE" ] && [ -f "$TPM_QUOTE_TOOLS_FILE" ]; then
    rm -rf $TPM_QUOTE_TOOLS
    tar fxz $TPM_QUOTE_TOOLS_FILE
	(cd $TPM_QUOTE_TOOLS &&  CFLAGS="-I$OPENSSL/include -I$TROUSERS/include" LDFLAGS="-L$OPENSSL/lib -L$TROUSERS/lib" ./configure --prefix=$PREFIX && make && make install)
  fi
}

install_tpm_quote_tools
