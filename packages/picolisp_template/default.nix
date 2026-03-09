{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.picolisp ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/picolisp && cp main.l $out/share/picolisp/main.l
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.picolisp}/bin/pil $out/share/picolisp/main.l" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "picolisp_template";
  src = ./.;
  version = "0.0.0";
}
