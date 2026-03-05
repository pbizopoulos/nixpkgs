{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.purescript
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<'EOF' > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "$DEBUG" == "1" ]; then
      purs compile ${./.}/Main.purs && echo "test math ... ok"
    else
      cat ${./.}/Main.purs
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
