{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.ldc
  ];
  buildPhase = "ldc2 main.d -of=d -w";
  installPhase = "install -Dm755 d $out/bin/${pname}";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
