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
      inputs.self.packages.${pkgs.stdenv.system}.${packageName}
    ];
    src = ../../packages/${packageName};
  }
  ''
    DEBUG=1 remove_empty_lines
    touch "$out"
  ''
