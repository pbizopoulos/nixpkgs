{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ${pname} $out/bin/${pname}
    runHook postInstall
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  pname = "uncomment";
  sourceRoot = ".";
  src = pkgs.fetchurl {
    sha256 = "sha256-EuRPTjg30QpIVw6ANblMtk9Rfwdnu+eWpCxdfOXIyvc=";
    url = "https://github.com/Goldziher/uncomment/releases/download/v2.11.0/uncomment-x86_64-unknown-linux-gnu.tar.gz";
  };
  version = "2.11.0";
}
