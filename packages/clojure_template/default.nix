{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
  script = pkgs.writeShellScriptBin pname ''
    root="$(cd "$(dirname "$0")/../lib/${pname}" && pwd)"
    clojure_jar=$(echo ${pkgs.clojure}/libexec/clojure-tools-*.jar)
    exec ${pkgs.openjdk}/bin/java -cp "$clojure_jar:$root/src/main/clojure" clojure.main -m main "$@"
  '';
in
pkgs.stdenv.mkDerivation rec {
  inherit pname;
  buildInputs = [
    pkgs.clojure
    pkgs.openjdk
  ];
  installPhase = ''
    mkdir -p $out/bin $out/lib/${pname}
    cp -r . $out/lib/${pname}
    rm -f $out/lib/${pname}/result
    cp -r ${script}/bin/* $out/bin/
  '';
  meta.mainProgram = pname;
  src = ./.;
  version = "0.0.0";
}
