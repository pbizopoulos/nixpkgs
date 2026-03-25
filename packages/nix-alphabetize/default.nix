{
  pkgs ? import <nixpkgs> { },
}:
pkgs.haskellPackages.mkDerivation rec {
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
  executableToolDepends = [
    pkgs.makeWrapper
  ];
  license = pkgs.lib.licenses.mit;
  mainProgram = pname;
  pname = baseNameOf ./.;
  postInstall = ''
    wrapProgram $out/bin/${pname} --run "rm -f tmp/${pname}.tix" --set-default HPCTIXFILE tmp/${pname}.tix
  '';
  src = ./.;
  version = "0.0.0";
}
