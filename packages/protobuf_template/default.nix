{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.protobuf
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<'EOF' > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "$DEBUG" == "1" ]; then
      protoc --proto_path=${./.} --encode=Hello ${./.}/main.proto <<<'text: "test"' > /dev/null && echo "test math ... ok"
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
