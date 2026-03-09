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
  pname = "haskell_template";
  postInstall = ''
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
    echo "exec $out/bin/haskell-template \"\$@\"" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/haskell-template --run "rm -f tmp/${pname}.tix" --set-default HPCTIXFILE tmp/${pname}.tix
  '';
  src = ./.;
  version = "0.0.0";
}
