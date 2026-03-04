{
  pkgs ? import <nixpkgs> { },
}:
pkgs.haskellPackages.mkDerivation rec {
  executableHaskellDepends = [
    pkgs.haskellPackages.HUnit
    pkgs.haskellPackages.base
  ];
  executableToolDepends = [ pkgs.makeWrapper ];
  pname = builtins.baseNameOf src;
  postInstall = ''
    wrapProgram $out/bin/${pname} --run "rm -f tmp/${pname}.tix" --set-default HPCTIXFILE tmp/${pname}.tix
  '';
  src = ./.;
  version = "0.0.0";
}
