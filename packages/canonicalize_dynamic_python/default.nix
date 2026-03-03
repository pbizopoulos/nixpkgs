{
  pkgs ? import <nixpkgs> { },
}:
let
  python = pkgs.python313.withPackages (ps: [
    ps.coverage
    ps.scalene
    ps.typer
    ps.vulture
  ]);
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ python ];
  installPhase = ''
    mkdir -p $out/bin
    cp main.py $out/bin/canonicalize_dynamic_python
    chmod +x $out/bin/canonicalize_dynamic_python
    wrapProgram $out/bin/canonicalize_dynamic_python \
      --prefix PATH : ${pkgs.lib.makeBinPath [ python pkgs.nix ]}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "canonicalize_dynamic_python";
  src = ./.;
  version = "0.0.0";
}
