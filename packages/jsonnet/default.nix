{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/lib/jsonnet
    cp main.jsonnet $out/lib/jsonnet/
    mkdir -p $out/bin
    makeWrapper ${pkgs.go-jsonnet}/bin/jsonnet $out/bin/${pname} \
      --add-flags "$out/lib/jsonnet/main.jsonnet"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
