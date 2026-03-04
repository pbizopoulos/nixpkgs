{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.kotlin ];
  buildPhase = "kotlinc main.kt -include-runtime -d ${pname}.jar";
  installPhase = ''
    mkdir -p $out/share/kotlin
    cp ${pname}.jar $out/share/kotlin/
    mkdir -p $out/bin
    makeWrapper ${pkgs.jre}/bin/java $out/bin/${pname} \
      --add-flags "-jar $out/share/kotlin/${pname}.jar"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
