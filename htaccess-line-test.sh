#!/bin/bash
# htaccess single line syntax test:
# Takes a single line and checks its syntax with apachectl.
# Usage example:
# $ echo "RewriteRule from /to? [L,NC,R=301]" | ./htaccess-line-test.sh
# $ echo "RewriteRule from /to? [L,NC,,R=301]" | ./htaccess-line-test.sh

read content
apachectl_bin='/usr/sbin/apachectl'
temp_dir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
composed_file="${temp_dir}/htaccess"
version=$(${apachectl_bin} -V | grep Apache | sed 's/.*Apache\/\(.*\) (Unix).*/\1/')
conf="apache.${version}.conf"
if [ ! -f $conf ]; then
    conf="apache.2.4.33.conf"
fi
cat $conf > "$composed_file"
cat "apache.${version}.conf" > "$composed_file"
echo "${content}" >> "$composed_file"
output=$(${apachectl_bin} -f "${composed_file}" 2>&1)

rm -r "${temp_dir}"

if echo "${output}" | grep --quiet --max-count=1 'Syntax error on line'
then
    echo "syntax error"
    exit 9
fi
