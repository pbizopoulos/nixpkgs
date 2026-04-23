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
      inputs.self.packages.${pkgs.stdenv.system}.${packageName}
    ];
    src = ../../packages/${packageName};
  }
  ''
    DEBUG=1 check_repository_directory_structure
    touch "$out"
  ''
