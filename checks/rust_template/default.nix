{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  inherit (inputs.self.packages.${pkgs.stdenv.system}.${builtins.baseNameOf ./.}) cargoDeps;
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
    export LIBCLANG_PATH='${pkgs.llvmPackages.libclang.lib}/lib'
    export LLVM_COV='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-cov"}'
    export LLVM_PROFDATA='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-profdata"}'
    cp -R --no-preserve=mode "$src" "$PWD/workspace"
    install -Dm644 "${cargoDeps}/.cargo/config.toml" "$PWD/workspace/.cargo/config.toml"
    substituteInPlace "$PWD/workspace/.cargo/config.toml" \
      --replace-fail "@vendor@" "${cargoDeps}"
    mkdir -p "$PWD/coverage"
    cd "$PWD/workspace"
    cargo llvm-cov --locked --no-report
    cargo llvm-cov report --html --output-dir "$PWD/coverage/html"
    cargo llvm-cov report --summary-only | tee "$PWD/coverage/summary.txt"
    mutation_status=0
    cargo mutants --no-config --colors never --cap-lints true --jobs 1 --output "$PWD/tmp" || mutation_status=$?
    if [ "$mutation_status" -ne 0 ] && [ "$mutation_status" -ne 2 ]; then
      exit "$mutation_status"
    fi
    touch "$out"
  ''
