{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.sqlite ];
  installPhase = ''
        mkdir -p $out/bin
        cp main.sql $out/bin/${pname}.sql
        cat <<EOF > $out/bin/${pname}
    #!/bin/bash
    if [ "\$DEBUG" == "1" ]; then
      ${pkgs.sqlite}/bin/sqlite3 :memory: ".read $out/bin/${pname}.sql"
    else
      echo "Hello SQL!"
    fi
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
