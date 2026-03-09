{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.pari ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/pari && cp main.gp $out/share/pari/main.gp
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.pari}/bin/gp -q $out/share/pari/main.gp" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "pari_template";
  src = ./.;
  version = "0.0.0";
}
