{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    ${pkgs.gnucobol}/bin/cobc -x -o ${pname} main.cob
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';
  nativeBuildInputs = [ pkgs.gnucobol ];
  pname = "cobol_template";
  src = ./.;
  version = "0.0.0";
}
