#!/bin/bash
buildSpecsDirectory="/home/robot/kw_build_specs"
tablesDirectory="/home/robot/kwtables"
klocworkProject="dcg_security-contrib"
klocworkServerUrl="https://klocwork-jf18.devtools.intel.com:8160"


initialize() {
  mkdir -p "${buildSpecsDirectory}"
  mkdir -p "${tablesDirectory}"
}

generateBuildSpecs() {
  export KWFLAGS_HEX2BIN="kwinject --output $buildSpecsDirectory/contrib_hex2bin.out"
  export KWFLAGS_TROUSERS="kwinject --output $buildSpecsDirectory/contrib_trousers.out"
  export KWFLAGS_NIARL="kwinject --output $buildSpecsDirectory/contrib_niarl.out"
  export KWFLAGS_TPM_AGENT_TOOLS="kwinject --output $buildSpecsDirectory/contrib_tpm_agent_tools.out"
  # TPM-TOOLS: see patch file to see altered parts of code; SDL fixes only required in code we added
  export KWFLAGS_TPM_TOOLS="kwinject --output $buildSpecsDirectory/contrib_tpm_tools.out"
  export KWFLAGS_TPM_TOOLS_ADDITIONS="kwinject --output $buildSpecsDirectory/contrib_tpm_tools_additions.out"
  ant
  
  # 'openssl', 'TPM quote tools', and 'tboot'
  # NOT required as we are downloading code from web and not altering
}

buildProject() {
  kwbuildproject --url "${klocworkServerUrl}/${klocworkProject}" --tables-directory "${tablesDirectory}" --force "${buildSpecsDirectory}/contrib_hex2bin.out" "${buildSpecsDirectory}/contrib_trousers.out" "${buildSpecsDirectory}/contrib_niarl.out" "${buildSpecsDirectory}/contrib_tpm_agent_tools.out" "${buildSpecsDirectory}/contrib_tpm_tools.out" "${buildSpecsDirectory}/contrib_tpm_tools_additions.out"
}

uploadResults() {
  kwadmin --url "${klocworkServerUrl}" load "${klocworkProject}" "${tablesDirectory}"
}

initialize
generateBuildSpecs
buildProject
uploadResults
