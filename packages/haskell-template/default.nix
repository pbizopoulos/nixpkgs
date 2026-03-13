{
  pkgs ? import <nixpkgs> { },
}:
pkgs.haskellPackages.mkDerivation rec {
  executableHaskellDepends = [
    pkgs.haskellPackages.HUnit
    pkgs.haskellPackages.aeson
    pkgs.haskellPackages.base
    pkgs.haskellPackages.bytestring
  ];
  executableToolDepends = [ pkgs.makeWrapper ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  postInstall = ''
    wrapProgram $out/bin/haskell-template --run "rm -f tmp/${pname}.tix" --set-default HPCTIXFILE tmp/${pname}.tix
  '';
  src = ./.;
  version = "0.0.0";
}
