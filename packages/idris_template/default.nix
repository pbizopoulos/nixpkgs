{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.idris2 ];
  buildPhase = ''
    idris2 main.idr -o ${pname}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -f build/exec/${pname} $out/bin/
    chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
