#!/bin/bash

# because some of these projects depend on the headers & libraries installed
# by other projects, the build order is important.  also, we "install" all 
# of the products into /opt/dcgcontrib



export PREFIX=${PREFIX:-/opt/dcgcontrib}
mkdir -p $PREFIX

# use "ldconfig -v" to see what libraries are cached, "ldconfig" to update cache,
# use "ldd /path/to/prog" to see what libraries are needed by that program,
# use "readelf -Ws /path/to/libxyz.so" to see what symbols are exported by libxyz.so
if [ -d /etc/ld.so.conf.d ]; then
  echo $PREFIX/lib > /etc/ld.so.conf.d/dcgcontrib.conf
fi

( cd hex2bin && ./build.sh )

( cd openssl && ./build.sh )

( cd trousers && ./build.sh )

( cd tpm-tools && ./build.sh )

( cd openssl-tpm-engine && ./build.sh )

