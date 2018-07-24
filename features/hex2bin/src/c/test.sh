#!/bin/sh

# globals

# the name of the current test; controlled by run_tests()
HEX2BIN_TEST=""

# input: $expected $observed
# input: global "$TEST" is test name to use in messages
# example: assert_equals zero "0" "0" ->  OK
# example: assert_equals zero "0" "1" ->  FAIL, expected '0', observed '1'
assert_equals() {
  local testname=${HEX2BIN_TEST:-"test"}
  local expected=$1
  local observed=$2
  if [ "$observed" == "$expected" ]; then
    echo "$testname: OK"
    return 0
  else
    echo "$testname: FAIL, expected '$expected', observed '$observed'"
    return 1
  fi  
}

run_tests() {
  local tests="$*"
  if [ -z "$tests" ]; then
    tests=$(declare -F | awk '{print $3}' | grep "^hex2bin_test_" | sed 's/^hex2bin_test_//g')
  fi
  for t in $tests
  do
    HEX2BIN_TEST=$t
    eval "hex2bin_test_$t"
  done
}

hex2bin_test_param_in_std_out() {
./hex2bin 00 > 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "00" "$result" 
}

hex2bin_test_param_in_file_out() {
./hex2bin 00 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "00" "$result"
}

hex2bin_test_std_in_std_out() {
echo 00 | ./hex2bin > 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "00" "$result"
}

hex2bin_test_std_in_file_out() {
echo 00 | ./hex2bin -stdin 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "00" "$result"
}

hex2bin_test_string() {
local input="00010203090a0b0d0e0f101112a3a9aaabfdfeff"
echo "$input" | ./hex2bin > 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "$input" "$result"
}

# on uneven input, the hex2bin utility stops after the last recognized byte
hex2bin_test_uneven_input() {
echo 001 | ./hex2bin > 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "00" "$result"
}

# on non-hex input, the hex2bin utility stops after the last recognized byte
hex2bin_test_nonhex_input() {
echo 00xx | ./hex2bin > 0.bin
local result=$(xxd -plain 0.bin)
assert_equals "00" "$result"
}

# run all defined tests
run_tests

# or run specified list of tests:
# run_tests "param_in_std_out param_in_file_out std_in_std_out std_in_file_out"

# cleanup
rm -rf 0.bin
