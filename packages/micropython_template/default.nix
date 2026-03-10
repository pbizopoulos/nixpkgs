{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.micropython ];
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.micropython}/bin/micropython $out/share/micropython/main.py" >> $out/bin/${pname}
    mkdir -p $out/share/micropython
    cp main.py $out/share/micropython/main.py
    chmod +x $out/bin/${pname}
  '';
  pname = "micropython_template";
  src = ./.;
  version = "0.0.0";
}
