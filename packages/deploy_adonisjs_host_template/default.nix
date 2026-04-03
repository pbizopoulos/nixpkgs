{
  inputs,
  pkgs ? import <nixpkgs> { },
}:
let
  installationScript = inputs.agenix-shell.lib.installationScript pkgs.stdenv.system {
    secrets.secrets.file = ../../secrets/secrets.age;
  };
  repoSrc = ../..;
in
pkgs.writeShellApplication {
  name = builtins.baseNameOf ./.;
  runtimeInputs = [
    pkgs.jq
    pkgs.openssh
    (pkgs.opentofu.withPlugins (p: [
      p.hashicorp_external
      p.hashicorp_local
      p.hashicorp_null
      p.hetznercloud_hcloud
    ]))
  ];
  text = ''
    # shellcheck disable=SC1091
    source ${pkgs.lib.getExe installationScript}
    set -a
    # shellcheck disable=SC1090,SC2154
    source "$secrets_PATH"
    set +a
    state_dir="$PWD/tmp"
    state_path="$state_dir/deploy_adonisjs_host_template.tfstate"
    workdir=$(mktemp -d)
    trap 'rm -rf "$workdir"' EXIT
    mkdir -p "$state_dir"
    cp -r ${repoSrc}/. "$workdir/"
    chmod -R u+w "$workdir"
    rm -rf "$workdir/packages/deploy_adonisjs_host_template/.terraform" "$workdir/packages/deploy_adonisjs_host_template/.terraform.lock.hcl"
    tofu -chdir="$workdir/packages/deploy_adonisjs_host_template" init -reconfigure \
      -backend-config="path=$state_path"
    tofu -chdir="$workdir/packages/deploy_adonisjs_host_template" apply
  '';
}
