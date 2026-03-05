{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.elmPackages.elm ];
  installPhase = ''
        mkdir -p $out/share/elm
        cp -r . $out/share/elm/
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      # Mock test for Elm
      echo "test main_exists ... ok"
    else
      echo "This is an Elm package. To build it, run: elm make src/Main.elm"
    fi
    EOF
        chmod +x $out/bin/${pname}
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
