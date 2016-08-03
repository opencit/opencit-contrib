#!/bin/bash
buildSpecsDirectory="/home/klocwork/kw_build_specs"
tablesDirectory="/home/klocwork/kwtables"
klocworkProject="dcg_security-contrib"
klocworkServerUrl="https://klocwork-jf18.devtools.intel.com:8160"

initialize() {
  mkdir -p "${buildSpecsDirectory}"
  mkdir -p "${tablesDirectory}"
}

generateBuildSpecs() {
  if [ ! -d "cit-patched-tpm-tools/target" ]; then
    (cd cit-patched-tpm-tools && mvn install)
  fi
  
  (cd cit-patched-tpm-tools/target/patched-tpm-tools-2.1-SNAPSHOT/tpm-tools-1.3.8-patched && LDFLAGS="-L/usr/local/lib" ./configure --prefix=/usr/local)
  (cd cit-patched-tpm-tools/target/patched-tpm-tools-2.1-SNAPSHOT/tpm-tools-1.3.8-patched && make clean)
  (cd cit-patched-tpm-tools/target/patched-tpm-tools-2.1-SNAPSHOT/tpm-tools-1.3.8-patched && kwinject --output "${buildSpecsDirectory}/tpm_tools_patched.out" make)
}

buildProject() {
  kwbuildproject --url "${klocworkServerUrl}/${klocworkProject}" --tables-directory "${tablesDirectory}" --force "${buildSpecsDirectory}/tpm_tools_patched.out"
}

uploadResults() {
  kwadmin --url "${klocworkServerUrl}" load "${klocworkProject}" "${tablesDirectory}"
}

initialize
generateBuildSpecs
buildProject
uploadResults
