{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.elmPackages.elm
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    echo "This is an Elm package. To build it, run: elm make src/Main.elm"
    EOF
        chmod +x $out/bin/${pname}
  '';
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
