{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.scala ];
  buildPhase = "scalac Main.scala -d .";
  installPhase = ''
    mkdir -p $out/share/scala
    cp *.class $out/share/scala/
    mkdir -p $out/bin
    makeWrapper ${pkgs.scala}/bin/scala $out/bin/${pname} \
      --add-flags "-cp $out/share/scala Main"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
