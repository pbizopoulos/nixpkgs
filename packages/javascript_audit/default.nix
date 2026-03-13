{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
  ];
  dontUnpack = true;
  installPhase = ''
    install -Dm755 ${src}/main.js $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nix
          pkgs.nodejs
        ]
      }
  '';
  meta = {
    mainProgram = pname;
    platforms = pkgs.lib.platforms.linux;
  };
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
