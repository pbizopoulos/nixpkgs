{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.powershell
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.ps1 $out/bin/${pname}.ps1
    makeWrapper ${pkgs.powershell}/bin/pwsh $out/bin/${pname} \
      --add-flags "-File $out/bin/${pname}.ps1"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
