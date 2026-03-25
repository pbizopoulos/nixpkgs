{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildPhase = ''
    export HOME=$TMPDIR
    latexmk -pdf -interaction=nonstopmode ms.tex > /dev/null 2>&1
  '';
  installPhase = ''
    install -Dm644 ms.pdf $out/share/ms.pdf
    install -Dm755 /dev/stdin $out/bin/${pname} <<EOF
    #!/usr/bin/env bash
    echo "Hello World"
    echo "PDF: $out/share/ms.pdf"
    EOF
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.texliveFull
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
