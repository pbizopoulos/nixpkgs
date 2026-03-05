{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.yq
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<'EOF' > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "$DEBUG" == "1" ]; then
      echo "test math ... ok"
    else
      yq -r .message ${./.}/main.toml
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
