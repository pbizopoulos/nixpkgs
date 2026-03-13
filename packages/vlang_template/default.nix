{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    export HOME=$TMPDIR
    ${pkgs.vlang}/bin/v -W -o ${pname} main.v
  '';
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
  '';
  nativeBuildInputs = [
    pkgs.vlang
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
