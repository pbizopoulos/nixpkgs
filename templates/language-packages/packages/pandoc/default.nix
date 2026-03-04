{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.haskellPackages.pandoc-crossref
    pkgs.pandoc
    pkgs.texlive.combined.scheme-small
  ];
  buildPhase = ''
    mkdir -p $out
    pandoc main.md \
      --filter pandoc-crossref \
      --citeproc \
      --pdf-engine=xelatex \
      -o $out/README.pdf
  '';
  phases = [
    "buildPhase"
    "unpackPhase"
  ];
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
