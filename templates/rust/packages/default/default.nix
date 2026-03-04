{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) rustPlatform;
in
rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-K98EVmRNfxSGbd3j6Gb6A2sozFBTQfUPsgBqPqs8i/Q=";
  nativeBuildInputs = [
    pkgs.pkg-config
    rustPlatform.bindgenHook
  ];
  pname = "rust";
  src = ./.;
  version = "0.1.0";
}
