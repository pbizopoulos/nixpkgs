{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nim
  ];
  buildPhase = "HOME=$TMPDIR nim c --warningAsError:on -o:nim main.nim";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./nim
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = "install -Dm755 nim $out/bin/${pname}";
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.valgrind
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
