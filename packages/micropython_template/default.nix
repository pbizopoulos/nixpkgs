{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.micropython ];
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.micropython}/bin/micropython $out/share/micropython/main.py" >> $out/bin/${pname}
    mkdir -p $out/share/micropython
    cp main.py $out/share/micropython/main.py
    chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
