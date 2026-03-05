{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.coq ];
  buildPhase = ''
    coqc main.v
  '';
  installPhase = ''
    mkdir -p $out/lib/coq/user-contrib/coq_template
    cp main.vo $out/lib/coq/user-contrib/coq_template/
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "echo 'Coq module compiled successfully'" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
