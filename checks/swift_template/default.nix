{
  inputs,
  pkgs,
  ...
}:
let
  pname = baseNameOf ./.;
  package = inputs.self.packages.${pkgs.stdenv.system}.${pname};
in
pkgs.runCommand "check-${pname}"
  {
    buildInputs = [
      package
    ];
  }
  ''
    DEBUG=1 ${pname}
    touch $out
  ''
