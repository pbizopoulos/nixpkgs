{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.texliveFull
  ];
  buildPhase = ''
    mkdir -p .cache/latex
    latexmk -interaction=nonstopmode -auxdir=.cache/latex -pdf ms.tex
  '';
  installPhase = ''
        mkdir -p $out/bin $out/share/doc
        cp ms.pdf $out/share/doc/
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    echo "This is a LaTeX package. The ms.pdf is located at $out/share/doc/ms.pdf"
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = "latex_template";
  src = ./.;
  version = "0.0.0";
}
