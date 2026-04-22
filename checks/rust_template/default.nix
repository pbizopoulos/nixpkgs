{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${name};
  cargoVendorConfig = pkgs.writeText "cargo-config.toml" ''
    [source.vendored-source-registry-0]
    directory = "${package.cargoDeps}/source-registry-0"
    [source.crates-io]
    replace-with = "vendored-source-registry-0"
  '';
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
    export CARGO_HOME="$build_dir/cargo-home"
    export CARGO_NET_OFFLINE=true
    export LIBCLANG_PATH='${pkgs.llvmPackages.libclang.lib}/lib'
    export LLVM_COV='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-cov"}'
    export LLVM_PROFDATA='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-profdata"}'
    export CARGO_TARGET_DIR="$build_dir/target"
    coverage_dir="$build_dir/coverage"
    rm -rf "$workspace"
    cp -R "$src" "$workspace"
    chmod -R u+w "$workspace"
    mkdir -p "$CARGO_HOME"
    install -m644 ${cargoVendorConfig} "$CARGO_HOME/config.toml"
    rm -rf "$coverage_dir"
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
