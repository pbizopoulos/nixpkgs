{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.erlang
  ];
  installPhase = ''
    install -Dm644 main.erl $out/share/erlang/main.erl
    install -d $out/bin
    makeWrapper ${pkgs.erlang}/bin/escript $out/bin/${pname} \
      --add-flags "$out/share/erlang/main.erl"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
