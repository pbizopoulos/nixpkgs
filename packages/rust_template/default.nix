{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  env.RUSTFLAGS = "-D warnings";
  buildInputs = [ ];
  cargoHash = "sha256-eYbFGvryzvF0Px0Iyfaws3fwWbSKUn/montDzNymyBc=";
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
