{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) rustPlatform;
in
rustPlatform.buildRustPackage rec {
  buildAndTestSubdir = "packages/default";
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-ZOIqujg9SLQMSWQffa0W78QOgmgOnhh+hWhHK8IC1Qs=";
  cargoRoot = "packages/default";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.makeWrapper
    pkgs.pkg-config
    rustPlatform.bindgenHook
  ];
  pname = "default";
  postInstall = ''
    wrapProgram $out/bin/${pname} \
      --set CANONICALIZATION_ROOT ${../../.} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.git
          pkgs.nix
        ]
      }
  '';
  preCheck = ''
    export CANONICALIZATION_ROOT=${../../.}
  '';
  src = ../..;
  version = "0.1.0";
}
