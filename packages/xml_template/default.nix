{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.libxml2
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      # Functional test: check if output is correct
      if [ "\$(${pkgs.libxml2}/bin/xmllint --xpath 'string(/message)' ${./.}/main.xml)" == "Hello XML!" ]; then
        echo "test ... ok"
      else
        echo "test ... failed"
        exit 1
      fi
    else
      ${pkgs.libxml2}/bin/xmllint --xpath "string(/message)" ${./.}/main.xml
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
