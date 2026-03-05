{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bash
    pkgs.wabt
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      # Meaningful test: validate WAT syntax by converting to WASM
      ${pkgs.wabt}/bin/wat2wasm ${./.}/main.wat -o /dev/null && echo "test ... ok"
    else
      cat ${./.}/main.wat
    fi
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
