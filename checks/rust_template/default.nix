{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
package.overrideAttrs (old: {
  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
    pkgs.cargo-llvm-cov
    pkgs.cargo-mutants
    pkgs.coreutils
    pkgs.llvmPackages.clang
    pkgs.llvmPackages.llvm
  ];
  postCheck = (old.postCheck or "") + ''
    export HOME="$TMPDIR"
    export LIBCLANG_PATH='${pkgs.llvmPackages.libclang.lib}/lib'
    export LLVM_COV='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-cov"}'
    export LLVM_PROFDATA='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-profdata"}'
    export CARGO_TARGET_DIR="$TMPDIR/target"
    coverage_dir="$TMPDIR/coverage"
    rm -rf "$coverage_dir"
    mkdir -p "$coverage_dir"
    cargo llvm-cov clean --workspace
    cargo llvm-cov --locked --no-report
    cargo llvm-cov report --html --output-dir "$coverage_dir/html"
    cargo llvm-cov report --summary-only | tee "$coverage_dir/summary.txt"
    rm -rf "$TMPDIR/mutants.out"
    set +e
    cargo mutants --no-config --colors never --cap-lints true --jobs 1 --output "$TMPDIR"
    mutation_status=$?
    set -e
    if [ "$mutation_status" -ne 0 ] && [ "$mutation_status" -ne 2 ]; then
      exit "$mutation_status"
    fi
  '';
})
