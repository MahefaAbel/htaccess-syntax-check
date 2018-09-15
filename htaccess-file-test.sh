#!/bin/bash
# htaccess file syntax test:
# Takes a file and checks its syntax with apachectl.
# Usage example:
# $ ./htaccess-line-test.sh htaccess.test

apachectl_bin='/usr/sbin/apachectl'
if [[ $# -eq 0 ]] ; then
    echo 'Feed me a existing file.'
    exit 0
fi

HTACCESSPATH="$1"
if [ ! -f $HTACCESSPATH ]; then
    echo 'File not found.'
    exit 0
fi

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")
composed_file="${temp_dir}/htaccess"
version=$(${apachectl_bin} -V | grep Apache | sed 's/.*Apache\/\(.*\) (Unix).*/\1/')
conf="${dir}/apache.${version}.conf"
if [ ! -f $conf ]; then
    conf="${dir}/apache.2.4.33.conf"
fi
cat $conf > "$composed_file"

output_tmp_path="${temp_dir}/output.tmp"
cat "${HTACCESSPATH}" >> "${composed_file}"

${apachectl_bin} -f "${composed_file}" >> "${output_tmp_path}" 2>&1
sed -i.bak 'N;s/:\n/: /' "${output_tmp_path}"

error=$(grep --max-count=1 'Syntax error on line' "${output_tmp_path}")
line_number=$(sed 's/.*line \(.*\) of.*/\1/' <<< "${error}")
line=$(sed -n "${line_number}p" "${composed_file}")
num_error=$(echo "$error" | sed '/^\s*$/d' | wc -l)
has_error=false
if [ "$num_error" -gt "0" ] ; then
  has_error=true
fi

if [ "$has_error" = true ] ; then
  echo "${line_number}: \"${line}\" ${error}"
fi

rm -r "${temp_dir}"

if [ "$has_error" = true ] ; then
  exit 9
fi
