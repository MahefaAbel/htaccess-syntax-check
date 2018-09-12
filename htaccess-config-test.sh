#!/bin/bash
APACHECTLBIN='/usr/sbin/apachectl'
HTACCESSPATH='/Users/tommy/projects/htaccess-syntax-check/htaccess.test'
HTACCESSTMPPATH='/Users/tommy/projects/htaccess-syntax-check/htaccess.tmp'
OUTPUT='/Users/tommy/projects/htaccess-syntax-check/output.tmp'
CONFIGPATH=$(apachectl -V | grep SERVER_CONFIG_FILE | cut -d '"' -f2)
cat "${CONFIGPATH}" > htaccess.tmp
cat "${HTACCESSPATH}" >> htaccess.tmp

$APACHECTLBIN -f "${HTACCESSTMPPATH}" >> "${OUTPUT}" 2>&1

ERRORSYNTAX=$(grep 'Syntax error' "${OUTPUT}")
NUMERRORSYNTAX=$(echo "$ERRORSYNTAX" | sed '/^\s*$/d' | wc -l)
HASERRORSYNTAX=false
if [ "$NUMERRORSYNTAX" -gt "0" ] ; then
  HASERRORSYNTAX=true
fi

if [ "$HASERRORSYNTAX" = true ] ; then
  echo "SYNTAX ERROR"
  echo "$ERRORSYNTAX"
  echo $NUMERRORSYNTAX
  echo ">>>"
  cat "${OUTPUT}"
  echo "<<<"
fi

# echo "$ERRORSYNTAX"
# echo $NUMERRORSYNTAX
# echo ">>>"
# cat "${OUTPUT}"
# echo "<<<"

rm *.tmp

if [ "$HASERRORSYNTAX" = true ] ; then
  exit 9
fi
