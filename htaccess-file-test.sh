#!/bin/bash
# htaccess file syntax test:
# Takes a file and checks its syntax with apachectl.
# Usage example:
# $ ./htaccess-line-test.sh htaccess.test

APACHECTLBIN='/usr/sbin/apachectl'
if [[ $# -eq 0 ]] ; then
    echo 'Feed me a existing file.'
    exit 0
fi

HTACCESSPATH="$1"
if [ ! -f $HTACCESSPATH ]; then
    echo 'File not found.'
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HTACCESSTMPPATH="${DIR}/htaccess.tmp"
OUTPUT="${DIR}/output.tmp"
# CONFIGPATH=$(apachectl -V | grep SERVER_CONFIG_FILE | cut -d '"' -f2)
APACHEVERSION=$(apachectl -V | grep Apache | sed 's/.*Apache\/\(.*\) (Unix).*/\1/')
CONFIGPATH="${DIR}/apache.${APACHEVERSION}.conf"
cat "${CONFIGPATH}" > "${HTACCESSTMPPATH}"
cat "${HTACCESSPATH}" >> "${HTACCESSTMPPATH}"

$APACHECTLBIN -f "${HTACCESSTMPPATH}" >> "${OUTPUT}" 2>&1
sed -i.bak 'N;s/:\n/: /' "${OUTPUT}"

ERRORSYNTAX=$(grep --max-count=1 'Syntax error on line' "${OUTPUT}")
LINENUMBER=$(sed 's/.*line \(.*\) of.*/\1/' <<< "${ERRORSYNTAX}")
LINE=$(sed -n "${LINENUMBER}p" "${HTACCESSTMPPATH}")
NUMERRORSYNTAX=$(echo "$ERRORSYNTAX" | sed '/^\s*$/d' | wc -l)
HASERRORSYNTAX=false
if [ "$NUMERRORSYNTAX" -gt "0" ] ; then
  HASERRORSYNTAX=true
fi

if [ "$HASERRORSYNTAX" = true ] ; then
  echo "${LINENUMBER}: \"${LINE}\" ${ERRORSYNTAX}"
fi

rm *.tmp *.tmp.bak

if [ "$HASERRORSYNTAX" = true ] ; then
  exit 9
fi
