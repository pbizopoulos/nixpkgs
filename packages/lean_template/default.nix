{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.lean4 ];
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pkgs.lean4}/bin/lean --run $out/share/lean/Main.lean" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    mkdir -p $out/share/lean
    cp Main.lean $out/share/lean/
  '';
  pname = "lean_template";
  src = ./.;
  version = "0.0.0";
}
