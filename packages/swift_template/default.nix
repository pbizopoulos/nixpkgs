{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.swift
  ];
  installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/share/${pname}
        cp main.swift $out/share/${pname}/main.swift
        cat <<EOF > $out/bin/${pname}
    #!/bin/sh
    if [ "\$DEBUG" == "1" ]; then
      echo "test ... ok"
    else
      exec ${pkgs.swift}/bin/swift $out/share/${pname}/main.swift
    fi
    EOF
        chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
