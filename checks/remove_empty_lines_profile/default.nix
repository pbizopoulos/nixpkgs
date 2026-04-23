{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "remove_empty_lines";
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
    temp_dir="$PWD/workspace"
    mkdir -p "$temp_dir"
    printf 'line1\n\nline2\n' > "$temp_dir/test.txt"
    perf record --call-graph dwarf -o perf.data -- \
      remove_empty_lines "$temp_dir"
    perf report --stdio -i perf.data
    touch "$out"
  ''
