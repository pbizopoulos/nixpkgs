{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  cargoHash = "sha256-eYbFGvryzvF0Px0Iyfaws3fwWbSKUn/montDzNymyBc=";
  doCheck = pkgs.stdenv.isLinux;
  env.RUSTFLAGS = "-D warnings";
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
