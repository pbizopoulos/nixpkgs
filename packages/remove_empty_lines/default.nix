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
  cargoHash = "sha256-aT64u3Tqrk+XXPptAtVs2EnVeOU2NCwSHg1XYeadZHs=";
}
