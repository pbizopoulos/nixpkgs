{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
  inherit (inputs.self.packages.${pkgs.stdenv.system}.${name}) cargoDeps;
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      pkgs.cargo
      pkgs.cargo-llvm-cov
      pkgs.cargo-mutants
      pkgs.llvmPackages.llvm
      pkgs.rustc
      pkgs.stdenv.cc
    ];
    src = ../../packages/${name};
  }
  ''
    export LLVM_COV='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-cov"}'
    export LLVM_PROFDATA='${pkgs.lib.getExe' pkgs.llvmPackages.llvm "llvm-profdata"}'
    cp -R --no-preserve=mode "$src" "$PWD/workspace"
    install -Dm644 "${cargoDeps}/.cargo/config.toml" "$PWD/workspace/.cargo/config.toml"
    substituteInPlace "$PWD/workspace/.cargo/config.toml" \
      --replace-fail "@vendor@" "${cargoDeps}"
    cd "$PWD/workspace"
    cargo llvm-cov --locked
    cargo mutants || mutation_status=$?
    case "''${mutation_status:-0}" in
      0 | 2) ;;
      *) exit "$mutation_status" ;;
    esac
    touch "$out"
  ''
