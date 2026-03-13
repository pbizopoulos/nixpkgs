{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nim
  ];
  buildPhase = "HOME=$TMPDIR nim c --warningAsError:on -o:nim main.nim";
  installPhase = "install -Dm755 nim $out/bin/${pname}";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./nim
  '';
  doCheck = pkgs.stdenv.isLinux;
  nativeCheckInputs = [ pkgs.valgrind ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
