#!/bin/bash
# htaccess single line syntax test:
# Takes a single line and checks its syntax with apachectl.
# Usage example:
# $ echo "RewriteRule from /to? [L,NC,R=301]" | ./htaccess-line-test.sh
# $ echo "RewriteRule from /to? [L,NC,,R=301]" | ./htaccess-line-test.sh

read content
apachectl='/usr/sbin/apachectl'
tempdir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
composedfile="${tempdir}/htaccess"
version=$(apachectl -V | grep Apache | sed 's/.*Apache\/\(.*\) (Unix).*/\1/')
conf="apache.${version}.conf"
if [ ! -f $conf ]; then
    conf="apache.2.4.33.conf"
fi
cat $conf > "$composedfile"
cat "apache.${version}.conf" > "$composedfile"
echo "${content}" >> "$composedfile"
output=$($apachectl -f "${composedfile}" 2>&1)

if echo "${output}" | grep --quiet --max-count=1 'Syntax error on line'
then
    echo "syntax error"
    exit 9
fi
