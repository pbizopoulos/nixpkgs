{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.rustPlatform.buildRustPackage {
  buildInputs = [ ];
  cargoHash = "sha256-eYbFGvryzvF0Px0Iyfaws3fwWbSKUn/montDzNymyBc=";
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = "rust_template";
  src = ./.;
  version = "0.0.0";
}
