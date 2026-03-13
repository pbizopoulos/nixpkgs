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
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.vlang
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
