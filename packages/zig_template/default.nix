{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ ];
  buildPhase = "HOME=$TMPDIR zig build -Doptimize=ReleaseSafe";
  installPhase = "HOME=$TMPDIR zig build install --prefix $out";
  checkPhase = ''
    DEBUG=1 valgrind --leak-check=full --error-exitcode=1 ./zig-out/bin/${pname}
  '';
  doCheck = pkgs.stdenv.isLinux;
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.zig
    pkgs.valgrind
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
