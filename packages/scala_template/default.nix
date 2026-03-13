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
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
