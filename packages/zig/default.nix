{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ ];
  buildPhase = "HOME=$TMPDIR zig build -Doptimize=ReleaseSafe --prefix $out";
  installPhase = ":";
  nativeBuildInputs = [ pkgs.zig ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
