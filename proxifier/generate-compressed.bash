#!/usr/bin/env bash
# Unofficial Bash Strict Mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# borrowed from https://stackoverflow.com/questions/16090869/how-to-pretty-print-xml-from-the-command-line
if command -v xmllint &>/dev/null; then
  cmd=(xmllint --format -)
elif command -v xml_pp &>/dev/null; then
  cmd=(xml_pp)
elif command -v xmlstarlet &>/dev/null; then
  cmd=(xmlstarlet
    format
    --indent-tab)
elif command -v tidy &>/dev/null; then
  cmd=(tidy
    -xml
    -i
    -q
    -)
else
  echo "No xml formatter is found. Please install one of the formatters:"
  echo "  xmllint, xml_pp, xmlstarlet, tidy"
fi

basedir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repodir="${basedir%/*}"
tempfile="${TMPDIR:-/tmp/}proxifer-rules.xml"

for item in proxifier.ppx proxifier-lite.ppx custom.ppx; do
  inputfile="${basedir}/${item}"
  outputfile="${repodir}/${item}"
  if [[ -f "$inputfile" ]]; then
    rm -f "$outputfile" 2>/dev/null
    <"$inputfile" sed '/<!--/d' | tr -d '\n' | tr -s ' ' | \
      sed 's/; /;/g' >"$outputfile"
    # output may be truncated by pipe, use temporary file
    # https://backreference.org/2011/01/29/in-place-editing-of-files/
    < "$outputfile" ${cmd[@]} >| "$tempfile"
    cp -f "$tempfile" "$outputfile"
  fi
done
