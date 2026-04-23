{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "default";
  repoRoot = ../../.;
in
pkgs.runCommand "${checkName}"
  {
    nativeBuildInputs = [
      inputs.self.packages.${pkgs.stdenv.system}.${packageName}
      pkgs.git
      pkgs.perf
    ];
    src = repoRoot;
  }
  ''
    export HOME="$PWD"
    workspace="$PWD/workspace"
    mkdir -p "$workspace/target"
    perf record --call-graph dwarf -o perf.data -- \
      env CANONICALIZATION_ROOT="$src" default "$workspace/target" --templates rust
    perf report --stdio -i perf.data
    touch "$out"
  ''
