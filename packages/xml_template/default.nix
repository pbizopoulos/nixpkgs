{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.libxml2
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<'EOF' > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "$DEBUG" == "1" ]; then
      xmllint ${./.}/main.xml > /dev/null && echo "test math ... ok"
    else
      xmllint --xpath "string(/message)" ${./.}/main.xml
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
