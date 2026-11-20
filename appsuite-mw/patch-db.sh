#!/bin/sh
# patch installed-db version records for the swapped wolfi packages.
set -eu
db="${1:?installed-db path}"
jdk_ver="${2:?openjdk version}"
expat_ver="${3:?libexpat version}"
awk -v jv="$jdk_ver" -v lv="$expat_ver" '
  /^P:openjdk-25-jre$/ || /^P:openjdk-25-default-jvm$/ { p="jdk"; print; next }
  /^P:libexpat1$/ { p="l"; print; next }
  p=="jdk" && /^V:/ { sub(/V:.*/, "V:" jv); p=""; print; next }
  p=="l"   && /^V:/ { sub(/V:.*/, "V:" lv); p=""; print; next }
  { print }
' "$db" > "$db.new"
mv "$db.new" "$db"
grep -A1 '^P:\(openjdk-25-jre\|openjdk-25-default-jvm\|libexpat1\)$' "$db"
