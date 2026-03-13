{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.ldc
  ];
  buildPhase = "ldc2 main.d -of=d";
  installPhase = "mkdir -p $out/bin && cp d $out/bin/${pname}";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
