#!/usr/bin/env bash
set -e
current_dir=$(dirname "$(realpath "$0")")
repository_dir=$(git -C "$current_dir" rev-parse --show-toplevel)
cd "${repository_dir}"/secrets && eval "$(nix run github:ryantm/agenix -- --decrypt secrets.age)" && cd -
nix-shell -p pkgs.jq 'pkgs.opentofu.withPlugins (p: [ p.hashicorp_external p.hashicorp_local p.hashicorp_null p.hetznercloud_hcloud ])' --command "
  export TF_VAR_hcloud_token=${HCLOUD_TOKEN}
  tofu -chdir=${current_dir} apply
"
