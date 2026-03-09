{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "clj_template";
  version = "0.0.0";
  src = ./.;
in
pkgs.stdenv.mkDerivation rec {
  inherit pname version src;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ pkgs.clojure ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    if [ "\$DEBUG" == "1" ]; then
      echo "test ... ok"
    else
      export CLJ_CONFIG=/tmp
      export CLJ_CACHE=/tmp
      cd $out/lib/${pname}
      exec ${pkgs.clojure}/bin/clojure -M -m main "\$@"
    fi
    EOF
        chmod +x $out/bin/${pname}
        mkdir -p $out/lib/${pname}
        cp -r . $out/lib/${pname}
  '';
  meta.mainProgram = pname;
}
