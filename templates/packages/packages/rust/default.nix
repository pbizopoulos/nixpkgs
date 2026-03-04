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
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.1.0";
}
