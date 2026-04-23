{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "check_repository_directory_structure";
in
pkgs.runCommand "${checkName}"
  {
    nativeBuildInputs = [
      pkgs.perf
      pkgs.git
      inputs.self.packages.${pkgs.stdenv.system}.${packageName}
    ];
    src = ../../packages/${packageName};
  }
  ''
    temp_dir="$PWD/repo"
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    git init -b main
    git config user.email test@example.com
    git config user.name "Test User"
    printf 'test\n' > flake.nix
    git add flake.nix
    git commit -m initial
    perf record --call-graph dwarf -o perf.data -- \
      check_repository_directory_structure flake.nix
    perf report --stdio -i perf.data
    touch "$out"
  ''
