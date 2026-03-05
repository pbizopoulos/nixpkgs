{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.factor-lang ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/factor && cp main.factor $out/share/factor/main.factor
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.factor-lang}/bin/factor $out/share/factor/main.factor" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
