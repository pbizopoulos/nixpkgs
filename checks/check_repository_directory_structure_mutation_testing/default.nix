{
  inputs,
  pkgs,
  ...
}:
let
  checkName = builtins.baseNameOf ./.;
  packageName = "check_repository_directory_structure";
  pkgConfigPath = pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
    pkgs.openssl
    pkgs.zlib
  ];
  inherit (inputs.self.packages.${pkgs.stdenv.system}.${packageName}) cargoDeps;
in
pkgs.runCommand "${checkName}"
  {
    buildInputs = [
      pkgs.openssl
      pkgs.zlib
    ];
    nativeBuildInputs = [
      pkgs.cargo
      pkgs.cargo-mutants
      pkgs.coreutils
      pkgs.llvmPackages.clang
      pkgs.git
      pkgs.pkg-config
      pkgs.rustc
      pkgs.stdenv.cc
    ];
    src = ../../packages/${packageName};
  }
  ''
    export LIBCLANG_PATH='${pkgs.llvmPackages.libclang.lib}/lib'
    export PKG_CONFIG_PATH='${pkgConfigPath}'
    cp -R --no-preserve=mode "$src" "$PWD/workspace"
    install -Dm644 "${cargoDeps}/.cargo/config.toml" "$PWD/workspace/.cargo/config.toml"
    substituteInPlace "$PWD/workspace/.cargo/config.toml" \
      --replace-fail "@vendor@" "${cargoDeps}"
    cd "$PWD/workspace"
    cargo mutants || mutation_status=$?
    if [ "''${mutation_status:-0}" != 0 ] && [ "''${mutation_status:-0}" != 2 ]; then
      exit "$mutation_status"
    fi
    touch "$out"
  ''
