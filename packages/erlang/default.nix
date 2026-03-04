{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.erlang ];
  buildPhase = "erlc main.erl";
  installPhase = ''
    mkdir -p $out/share/erlang
    cp main.beam $out/share/erlang/
    mkdir -p $out/bin
    makeWrapper ${pkgs.erlang}/bin/erl $out/bin/${pname} \
      --add-flags "-noshell -pa $out/share/erlang -s main main -s init stop"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
