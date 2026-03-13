{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.ldc
  ];
  buildPhase = "ldc2 main.d -of=d -w";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./d
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = "install -Dm755 d $out/bin/${pname}";
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.valgrind
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
