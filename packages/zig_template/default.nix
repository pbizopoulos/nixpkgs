{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ ];
  buildPhase = "HOME=$TMPDIR zig build -Doptimize=ReleaseSafe";
  installPhase = "HOME=$TMPDIR zig build install --prefix $out";
  nativeBuildInputs = [
    pkgs.zig
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
