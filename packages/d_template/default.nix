{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.ldc
  ];
  buildPhase = "ldc2 main.d -of=d -w";
  installPhase = "install -Dm755 d $out/bin/${pname}";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./d
  '';
  doCheck = pkgs.stdenv.isLinux;
  nativeCheckInputs = [ pkgs.valgrind ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
