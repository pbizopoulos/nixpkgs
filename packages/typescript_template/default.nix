{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
  ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags $out/lib/${pname}/scripts/start.js \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
        ]
      }
    runHook postInstall
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
