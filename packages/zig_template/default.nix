{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ ];
  buildPhase = "HOME=$TMPDIR zig build -Doptimize=ReleaseSafe";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./zig-out/bin/${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  installPhase = "HOME=$TMPDIR zig build install --prefix $out";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.valgrind
    pkgs.zig
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
