#!/usr/bin/env bash
set -euo pipefail
current_dir=$(dirname "$(realpath "$0")")
repository_dir=$(git -C "$current_dir" rev-parse --show-toplevel)
cd "${repository_dir}/secrets"
eval "$(nix run github:ryantm/agenix -- --decrypt secrets.age)"
cd "${repository_dir}"
nixos_config_name=${NIXOS_CONFIG_NAME:-${TF_VAR_nixos_config_name:-adonisjs_host_template}}
ipv4_address=${IPV4_ADDRESS:-}
if [ -z "${ipv4_address}" ] && [ -f "${repository_dir}/packages/deploy/prm/ipv4_address" ]; then
  ipv4_address=$(cat "${repository_dir}/packages/deploy/prm/ipv4_address")
fi
: "${ipv4_address:?IPV4_ADDRESS must be set or packages/deploy/prm/ipv4_address must exist}"
ssh-keygen -R "${ipv4_address}" || true
scp "root@${ipv4_address}:/etc/ssh/ssh_host_ed25519_key.pub" "${repository_dir}/prm/${nixos_config_name}.pub"
bash "${repository_dir}/prm/agenix-rekey.sh"
