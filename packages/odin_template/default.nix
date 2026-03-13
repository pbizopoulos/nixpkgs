{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.odin
  ];
  buildPhase = "HOME=\$TMPDIR odin build . -out:\${pname} -o:speed -vet";
  installPhase = "mkdir -p $out/bin && cp ${pname} $out/bin/";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
