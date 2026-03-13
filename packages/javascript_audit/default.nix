{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
  ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${src}/main.js $out/bin/${pname}
    chmod +x $out/bin/${pname}
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
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
