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
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.vlang
    pkgs.valgrind
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
