#!/bin/sh
set -e
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
case "${1:-}" in
-h | --help | help)
  cat <<'EOF'
git-inverse: track files ignored by the main Git repository
Usage:
  git-inverse <git-command> [args...]
Runs Git commands in the inverse repository (.gitinverse), which tracks
only files ignored by the main repository. Temporarily inverts .gitignore
rules so normally ignored files become trackable.
EOF
  exit 0
  ;;
esac
if [ -d "$repo_root/.gitinverse" ]; then
  echo "*" >"$repo_root/.gitinverse/.gitignore"
  git -C "$repo_root" ls-files "$(git rev-parse --show-toplevel)" >"$repo_root/.gitinverse/info/exclude"
  git --git-dir="$repo_root/.gitinverse" --work-tree="$repo_root" config diff.tool imagemagick
  # shellcheck disable=SC2016
  git --git-dir="$repo_root/.gitinverse" --work-tree="$repo_root" config difftool.imagemagick.cmd 'compare "$LOCAL" "$REMOTE" "$LOCAL-diff.png"'

fi
if [ -f "$repo_root/.gitignore" ]; then
  mv "$repo_root/.gitignore" "/tmp/.gitignore.orig"
  # shellcheck disable=SC2016
  restore_cmd='mv "/tmp/.gitignore.orig" "$repo_root/.gitignore"'
else
  # shellcheck disable=SC2016
  restore_cmd='rm -f "$repo_root/.gitignore"'
fi
# shellcheck disable=SC2064
trap "$restore_cmd" EXIT
git --git-dir="$repo_root/.gitinverse" --work-tree="$repo_root" "$@"
