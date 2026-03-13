{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    mkdir -p $out/lib/fennel
    cp main.fnl $out/lib/fennel/
    mkdir -p $out/bin
    makeWrapper ${pkgs.luaPackages.fennel}/bin/fennel $out/bin/${pname} \
      --add-flags "$out/lib/fennel/main.fnl"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
