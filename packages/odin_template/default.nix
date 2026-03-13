{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.odin
  ];
  buildPhase = "HOME=$TMPDIR odin build . -out:\${pname} -o:speed -vet";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = "install -Dm755 ${pname} $out/bin/${pname}";
  meta.mainProgram = pname;
  nativeCheckInputs = [
    pkgs.valgrind
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
