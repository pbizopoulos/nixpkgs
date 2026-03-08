{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.gfortran ];
  buildPhase = "gfortran -o ${pname} main.f90";
  installPhase = ''
    mkdir -p $out/bin
    cp -f ${pname} $out/bin/
    chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = "fortran_template";
  src = ./.;
  version = "0.0.0";
}
