#!/bin/sh

main_py="$(realpath "${1%%#*}")/packages/${1##*#}/main.py"
coverage_dir="$(dirname "$main_py")/tmp/coverage"
scalene_dir="$(dirname "$main_py")/tmp/scalene"
mkdir -p "$scalene_dir"
# shellcheck disable=SC2016
nix develop "$1" --command nix-shell -p python312Packages.coverage python312Packages.scalene --command '
  set -eu
  DEBUG=1 coverage run --data-file="'"$coverage_dir"'/.coverage" "'"$main_py"'"
  coverage html --data-file="'"$coverage_dir"'/.coverage" --directory="'"$coverage_dir"'" --ignore-errors
  DEBUG=1 scalene --outfile "'"$scalene_dir"'/profile.html" "'"$main_py"'"
'
