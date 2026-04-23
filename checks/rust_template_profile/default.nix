{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "rust_template";
in
pkgs.runCommand "${checkName}"
  {
    nativeBuildInputs = [
      pkgs.perf
      inputs.self.packages.${pkgs.stdenv.system}.${packageName}
    ];
    src = ../../packages/${packageName};
  }
  ''
    perf record --call-graph dwarf -o perf.data -- rust_template
    perf report --stdio -i perf.data
    touch "$out"
  ''
