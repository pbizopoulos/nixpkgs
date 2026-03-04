{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) rustPlatform;
in

rustPlatform.buildRustPackage rec {
  pname = "rust";
  version = "0.1.0";
  src = ./.;
  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkgs.pkg-config
  ];
  buildInputs = [
    # Add libraries your crate depends on, e.g.,
    # pkgs.openssl
  ];
  cargoHash = "sha256-K98EVmRNfxSGbd3j6Gb6A2sozFBTQfUPsgBqPqs8i/Q=";
}
