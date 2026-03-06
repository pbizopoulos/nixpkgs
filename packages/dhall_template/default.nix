{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    ${pkgs.dhall}/bin/dhall text --file ${./main.dhall}
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
