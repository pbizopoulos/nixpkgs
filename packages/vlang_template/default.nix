{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    export HOME=$TMPDIR
    ${pkgs.vlang}/bin/v -W -o ${pname} main.v
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/
  '';
  nativeBuildInputs = [
    pkgs.vlang
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
