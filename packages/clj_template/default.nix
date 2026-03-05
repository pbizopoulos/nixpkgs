{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.clojure ];
  installPhase = ''
    mkdir -p $out/share/clojure
    cp -r . $out/share/clojure/
    mkdir -p $out/bin
    makeWrapper ${pkgs.clojure}/bin/clojure $out/bin/${pname} \
      --add-flags "-M -m main" \
      --set CLJ_CONFIG /tmp \
      --set CLJ_CACHE /tmp \
      --run "cd $out/share/clojure"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
