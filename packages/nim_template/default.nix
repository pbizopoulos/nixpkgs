{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nim
  ];
  buildPhase = "HOME=$TMPDIR nim c --warningAsError:on -o:nim main.nim";
  installPhase = "install -Dm755 nim $out/bin/${pname}";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
