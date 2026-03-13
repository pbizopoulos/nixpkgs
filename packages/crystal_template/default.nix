{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.crystal
  ];
  buildPhase = ''
    crystal build main.cr -o ${pname} --warnings all --error-on-warnings
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -f ${pname} $out/bin/
    chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
