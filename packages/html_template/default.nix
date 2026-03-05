{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.bash ];
  installPhase = ''
        mkdir -p $out/share/doc
        cp -f ${./.}/* $out/share/doc/
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      for f in index.html style.css script.js; do
        if [ -f $out/share/doc/\$f ]; then
          echo "test \$f ... ok"
        else
          echo "test \$f ... failed"
          exit 1
        fi
      done
    else
      ${pkgs.nodePackages.http-server}/bin/http-server $out/share/doc
    fi
    EOF
        chmod +555 $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
