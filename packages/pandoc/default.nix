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
    pandoc main.md \
      --filter pandoc-crossref \
      --citeproc \
      --pdf-engine=xelatex \
      -o README.pdf
  '';
  installPhase = ''
        mkdir -p $out/share/doc
        cp -f README.pdf $out/share/doc/
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      if [ -f $out/share/doc/README.pdf ]; then
        echo "test pdf_exists ... ok"
      else
        echo "test pdf_exists ... failed"
        exit 1
      fi
    else
      echo "This is a document package. The README.pdf is located at $out/share/doc/README.pdf"
    fi
    EOF
        chmod +555 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
