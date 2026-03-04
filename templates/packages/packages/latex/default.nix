{
  pkgs ? import <nixpkgs> { },
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
        mkdir -p $out/share/doc
        cp -f ms.pdf $out/share/doc/
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      if [ -f $out/share/doc/ms.pdf ]; then
        echo "test pdf_exists ... ok"
      else
        echo "test pdf_exists ... failed"
        exit 1
      fi
    else
      echo "This is a LaTeX package. The ms.pdf is located at $out/share/doc/ms.pdf"
    fi
    EOF
        chmod +555 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
