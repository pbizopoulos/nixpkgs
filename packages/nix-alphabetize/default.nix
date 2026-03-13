{
  pkgs ? import <nixpkgs> { },
}:
let
  drv = pkgs.haskellPackages.mkDerivation rec {
    description = "Sorts attributes alphabetically, using dotted notation for attributes with sets or lists, and nested notation otherwise";
    executableHaskellDepends = [
      pkgs.haskellPackages.HUnit
      pkgs.haskellPackages.base
      pkgs.haskellPackages.data-fix
      pkgs.haskellPackages.hnix
      pkgs.haskellPackages.prettyprinter
      pkgs.haskellPackages.temporary
      pkgs.haskellPackages.text
    ];
    pname = baseNameOf ./.;
    src = ./.;
    version = "0.0.0";
  };
in
drv
// {
  meta = (drv.meta or { }) // {
    mainProgram = drv.pname;
  };
}
