#!/usr/bin/env bash
set -e
current_dir=$(dirname "$(realpath "$0")")
nixos_config_name=$(basename "$current_dir")
repository_dir=$(git -C "$current_dir" rev-parse --show-toplevel)
touch "${repository_dir}/prm/${nixos_config_name}.pub"
cd "${repository_dir}"/secrets && eval "$(nix run github:ryantm/agenix -- --decrypt secrets.age)" && cd -
nix-shell -p pkgs.jq 'pkgs.opentofu.withPlugins (p: [ p.hashicorp_external p.hashicorp_local p.hashicorp_null p.hetznercloud_hcloud ])' --command "
  export TF_VAR_hcloud_token=${HCLOUD_TOKEN}
  tofu -chdir=${current_dir} init
  tofu -chdir=${current_dir} apply
"
IPV4_ADDRESS=$(cat "${current_dir}/prm/ipv4_address")
ssh-keygen -R "${IPV4_ADDRESS}"
scp root@"${IPV4_ADDRESS}:/etc/ssh/ssh_host_ed25519_key.pub" "${repository_dir}/prm/${nixos_config_name}.pub"
cd "${repository_dir}"/secrets && nix run github:ryantm/agenix -- --rekey && cd -
