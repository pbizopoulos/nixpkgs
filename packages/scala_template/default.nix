{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.scala
  ];
  buildPhase = "scalac Main.scala -d . -Xfatal-warnings";
  installPhase = ''
    install -Dm644 -t $out/share/scala *.class
    install -d $out/bin
    makeWrapper ${pkgs.scala}/bin/scala $out/bin/${pname} \
      --add-flags "-cp $out/share/scala Main"
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
