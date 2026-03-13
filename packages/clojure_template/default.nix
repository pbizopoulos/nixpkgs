{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.clojure
  ];
  installPhase = ''
        mkdir -p $out/bin
        cat <<EOF > $out/bin/${pname}
    #!/usr/bin/env bash
    export CLJ_CONFIG=/tmp
    export CLJ_CACHE=/tmp
    cd $out/lib/${pname}
    exec ${pkgs.clojure}/bin/clojure -M -m main "\$@"
    EOF
        chmod +x $out/bin/${pname}
        mkdir -p $out/lib/${pname}
        cp -r . $out/lib/${pname}
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
