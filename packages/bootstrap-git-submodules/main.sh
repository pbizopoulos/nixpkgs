#!/bin/sh
set -e

repository_domain=github.com
git init "$HOME"
printf '*\n!.gitignore\n' >"$HOME/.gitignore"
gh auth status --hostname "$repository_domain" || gh auth login --git-protocol ssh --hostname "$repository_domain" --web
gh repo list | while read -r repo _; do
  git -C "$HOME" submodule add --force git@"$repository_domain:$repo" "$repository_domain/$repo"
done
gh org list | while read -r org _; do
  gh repo list "$org" | while read -r repo _; do
    git -C "$HOME" submodule add --force git@"$repository_domain:$repo" "$repository_domain/$repo"
  done
done
