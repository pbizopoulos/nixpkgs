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
    ls ${package}/bin/${pname}
    touch $out
  ''
