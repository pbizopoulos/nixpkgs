{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.coq ];
  buildPhase = ''
    coqc main.v
  '';
  installPhase = ''
        mkdir -p $out/lib/coq/user-contrib/${pname}
        cp main.vo $out/lib/coq/user-contrib/${pname}/
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    echo "Coq module compiled successfully"
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
