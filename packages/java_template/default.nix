{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.jdk
  ];
  buildPhase = "javac src/main/java/Main.java -d . -Xlint:all -Werror";
  installPhase = ''
    install -Dm644 Main.class $out/share/java/Main.class
    install -d $out/bin
    makeWrapper ${pkgs.jdk}/bin/java $out/bin/${pname} \
      --add-flags "-cp $out/share/java Main"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
