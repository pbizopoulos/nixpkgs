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
      pkgs.pprof
      inputs.self.packages.${pkgs.stdenv.system}.${packageName}
    ];
    src = ../../packages/${packageName};
  }
  ''
    DEBUG=1 rust_template
    touch "$out"
  ''
