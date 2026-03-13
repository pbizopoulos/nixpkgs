{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.odin
  ];
  buildPhase = "HOME=$TMPDIR odin build . -out:\${pname} -o:speed -vet";
  installPhase = "install -Dm755 ${pname} $out/bin/${pname}";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  nativeCheckInputs = [ pkgs.valgrind ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
