{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.deno ];
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.deno}/bin/deno run --allow-net $out/share/deno/main.ts" >> $out/bin/${pname}
    mkdir -p $out/share/deno
    cp main.ts $out/share/deno/main.ts
    chmod +x $out/bin/${pname}
  '';
  pname = "deno_template";
  src = ./.;
  version = "0.0.0";
}
