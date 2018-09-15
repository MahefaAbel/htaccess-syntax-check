#!/bin/bash
PASS=0
FAIL=0
assert_exit_code_equals(){
  expected=$1
  actual=$2
  if [ $actual -ne $expected ]; then
    printf "F"
    FAIL=$((FAIL+1))
  else
    printf "."
    PASS=$((PASS+1))
  fi
}

# file
test_file_valid=$(./htaccess-file-test.sh htaccess.valid.test)
assert_exit_code_equals 0 $?
test_file_invalid=$(./htaccess-file-test.sh htaccess.invalid.test)
assert_exit_code_equals 9 $?

# line
test_line_valid_1=$(echo "RewriteRule old /new" | ./htaccess-line-test.sh)
assert_exit_code_equals 0 $?
test_line_valid_2=$(echo "RewriteRule old /new? [R=301]" | ./htaccess-line-test.sh)
assert_exit_code_equals 0 $?
test_line_valid_3=$(echo "RewriteRule old-no-2 /nl/flags? [R=302]" | ./htaccess-line-test.sh)
assert_exit_code_equals 0 $?
test_line_invalid_1=$(echo "RewriteRule old /new? [R=301, ]" | ./htaccess-line-test.sh)
assert_exit_code_equals 9 $?

echo ""
echo "PASS ${PASS} FAIL ${FAIL}"
if [ $FAIL -ne 0 ]; then exit 9; fi
