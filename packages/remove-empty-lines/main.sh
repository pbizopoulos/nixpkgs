#!/usr/bin/env bash
file="$1"
if [ ! -f "$file" ]; then
  exit 1
fi
sed -i '/^[[:space:]]*$/d' "$file"
