{
  inputs,
  pkgs,
  ...
}:
let
  name = "rust_template";
  inherit (inputs.self.packages.${pkgs.stdenv.system}.${name}) cargoDeps;
in
pkgs.runCommand "${name}"
  {
    nativeBuildInputs = [
      pkgs.cargo
      pkgs.cargo-llvm-cov
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
    cargo llvm-cov
    touch "$out"
  ''
