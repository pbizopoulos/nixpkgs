{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.isabelle ];
  buildPhase = ''
    export HOME=$TMPDIR
    isabelle build -D .
  '';
  installPhase = ''
    mkdir -p $out/share/isabelle
    cp -r . $out/share/isabelle/
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "echo 'Isabelle session built successfully'" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
