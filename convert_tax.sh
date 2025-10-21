#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
out="${2:-/dev/stdout}"

if [[ -z "$file" ]]; then
  echo "Usage: $0 input.csv [output.csv]" >&2
  exit 2
fi

awk -F',' '
BEGIN { OFS=","; t=0 }

NR==1 {
  for (i=1; i<=NF; i++) {
    h = $i
    gsub(/^"|"$/, "", h)
    if (h == "tax") { t = i; break }
  }
  if (!t) { print "ERROR: no tax column" > "/dev/stderr"; exit 1 }
  print $0
  next
}

{
  val = $t
  if (val ~ /^0(\.[0-9]{1,2})?$/ || val ~ /^1(\.0{1,2})?$/) {
    $t = sprintf("%.0f", val * 100) "%"
  }
  print $0
}
' "$file" > "$out"
