{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.swi-prolog ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/prolog && cp main.pl $out/share/prolog/main.pl
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.swi-prolog}/bin/swipl -q -t main -s $out/share/prolog/main.pl" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "prolog_template";
  src = ./.;
  version = "0.0.0";
}
