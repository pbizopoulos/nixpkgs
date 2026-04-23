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
    ];
    src = repoRoot;
  }
  ''
    export HOME="$PWD"
    workspace="$PWD/workspace"
    mkdir -p "$workspace/target"
    CANONICALIZATION_ROOT="$src" DEBUG=1 default "$workspace/target" --templates rust
    touch "$out"
  ''
