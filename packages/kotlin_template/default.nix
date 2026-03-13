{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.kotlin
  ];
  buildPhase = "kotlinc Main.kt -include-runtime -d ${pname}.jar -Werror";
  installPhase = ''
    install -Dm644 ${pname}.jar $out/share/kotlin/${pname}.jar
    install -d $out/bin
    makeWrapper ${pkgs.jre}/bin/java $out/bin/${pname} \
      --add-flags "-cp $out/share/kotlin/${pname}.jar MainKt"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
