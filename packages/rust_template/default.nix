{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-K98EVmRNfxSGbd3j6Gb6A2sozFBTQfUPsgBqPqs8i/Q=";
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
