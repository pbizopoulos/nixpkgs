{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.bash ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    cat ${./main.kdl}
    EOF
        chmod 755 $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
