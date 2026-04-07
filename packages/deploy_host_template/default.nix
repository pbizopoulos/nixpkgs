{
  inputs,
  pkgs ? import <nixpkgs> { },
}:
let
  installationScript = inputs.agenix-shell.lib.installationScript pkgs.stdenv.system {
    secrets.secrets.file = ../../secrets/secrets.age;
  };
  packageRelativePath = "packages/deploy_host_template";
  repoSrc = ../..;
in
pkgs.writeShellApplication {
  name = builtins.baseNameOf ./.;
  runtimeInputs = [
    pkgs.git
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
    repo_root="$(git rev-parse --show-toplevel)"
    package_dir="$repo_root/${packageRelativePath}"
    state_dir="$package_dir/tmp"
    state_path="$state_dir/deploy_host_template.tfstate"
    workdir=$(mktemp -d)
    trap 'rm -rf "$workdir"' EXIT
    mkdir -p "$state_dir"
    cp -r ${repoSrc}/. "$workdir/"
    chmod -R u+w "$workdir"
    work_package_dir="$workdir/${packageRelativePath}"
    rm -rf "$work_package_dir/.terraform" "$work_package_dir/.terraform.lock.hcl"
    tofu -chdir="$work_package_dir" init -reconfigure \
      -backend-config="path=$state_path"
    tofu -chdir="$work_package_dir" apply \
      -var="output_dir=$state_dir"
  '';
}
