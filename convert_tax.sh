#!/usr/bin/env bash
set -euo pipefail

file="${1:-}"
out="${2:-/dev/stdout}"

if [[ -z "$file" ]]; then
  echo "Usage: $0 input.csv [output.csv]" >&2
  exit 2
fi

[[ -f "$file" ]] || { echo "ERROR: file not found: $file" >&2; exit 2; }
if ! head -n1 "$file" | grep -qE '(^|,)"?tax"?($|,)'; then
  echo "ERROR: No 'tax' column in header" >&2
  exit 1
fi

LC_ALL=C awk -F',' '
BEGIN { OFS=","; t=0 }

NR==1 {
  sub(/\r$/, "", $0)
  for (i=1; i<=NF; i++) {
    h = $i
    gsub(/^ +| +$/, "", h)
    gsub(/^"|"$/, "", h)
    if (h == "tax") { t = i; break }
  }
  if (!t) { print "ERROR: no tax column" > "/dev/stderr"; exit 1 }
  print $0
  next
}

{
  sub(/\r$/, "", $0)
  val = $t
  gsub(/^ +| +$/, "", val)
  gsub(/^"|"$/, "", val)
  if (val ~ /^(100|[1-9]?[0-9])%$/) {
  } else if (val ~ /^0(\.[0-9]{1,2})?$/ || val ~ /^1(\.0{1,2})?$/) {
    $t = sprintf("%.0f", val * 100) "%"
  } else {
    $t = "N/A"
  }

  print $0
}
' "$file" > "$out"
BASH 
