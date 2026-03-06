{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    ${pkgs.go-jsonnet}/bin/jsonnet ${./main.jsonnet}
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
