{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-eYbFGvryzvF0Px0Iyfaws3fwWbSKUn/montDzNymyBc=";
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.0.0";
}
