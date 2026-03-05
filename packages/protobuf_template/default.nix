{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.protobuf
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      # Functional test: ensure we can read the file
      if [ -f ${./.}/main.proto ]; then
        echo "test ... ok"
      else
        echo "test ... failed"
        exit 1
      fi
    else
      cat ${./.}/main.proto
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
