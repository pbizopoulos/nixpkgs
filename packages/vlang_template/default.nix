{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    export HOME=$TMPDIR
    ${pkgs.vlang}/bin/v -W -o ${pname} main.v
  '';
  checkPhase = ''
    ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = ''
    install -Dm755 ${pname} $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.valgrind
    pkgs.vlang
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
