{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      pkgs.cargo
      pkgs.cargo-llvm-cov
      pkgs.cargo-mutants
      pkgs.coreutils
      pkgs.llvmPackages.clang
      pkgs.llvmPackages.llvm
      pkgs.rustc
      pkgs.stdenv.cc
    ];
    src = ../../packages/${name};
  }
  ''
    build_dir="$PWD"
    workspace="$build_dir/workspace"
    export HOME="$build_dir"
    export LIBCLANG_PATH='${pkgs.llvmPackages.libclang.lib}/lib'
    export LLVM_COV='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-cov"}'
    export LLVM_PROFDATA='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-profdata"}'
    export CARGO_TARGET_DIR="$build_dir/target"
    coverage_dir="$build_dir/coverage"
    cp -R "$src" "$workspace"
    chmod -R u+w "$workspace"
    cp -R "${package.cargoDeps}/.cargo" "$workspace/"
    substituteInPlace "$workspace/.cargo/config.toml" \
      --replace-fail "@vendor@" "${package.cargoDeps}"
    mkdir -p "$coverage_dir"
    cd "$workspace"
    cargo llvm-cov clean --workspace
    cargo llvm-cov --locked --no-report
    cargo llvm-cov report --html --output-dir "$coverage_dir/html"
    cargo llvm-cov report --summary-only | tee "$coverage_dir/summary.txt"
    mkdir -p "$build_dir/tmp"
    rm -rf "$build_dir/tmp/mutants.out"
    set +e
    cargo mutants --no-config --colors never --cap-lints true --jobs 1 --output "$build_dir/tmp"
    mutation_status=$?
    set -e
    if [ "$mutation_status" -ne 0 ] && [ "$mutation_status" -ne 2 ]; then
      exit "$mutation_status"
    fi
    touch "$out"
  ''
