{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
  script = pkgs.writeShellScriptBin pname ''
    export CLJ_CONFIG=/tmp
    export CLJ_CACHE=/tmp
    exec ${pkgs.clojure}/bin/clojure -M -m main "$@"
  '';
in
pkgs.stdenv.mkDerivation rec {
  inherit pname;
  version = "0.0.0";
  src = ./.;

  buildInputs = [ pkgs.clojure ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/${pname}
    cp -r . $out/lib/${pname}
    rm -f $out/lib/${pname}/result
    cp -r ${script}/bin/* $out/bin/
  '';
  meta.mainProgram = pname;
}
