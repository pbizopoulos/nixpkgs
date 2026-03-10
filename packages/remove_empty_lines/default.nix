{ pkgs ? import <nixpkgs> {} }:
  pkgs.rustPlatform.buildRustPackage rec {
    buildInputs = [];
    cargoHash = "sha256-+zw72kFphEKceFEgjcZn8uHsVWTz38pNXgOIzvFn9cY=";
    meta.mainProgram = pname;
    nativeBuildInputs = [
      (pkgs.pkg-config)
      (pkgs.rustPlatform.bindgenHook)
    ];
    pname = "remove_empty_lines";
    src = ./.;
    version = "0.1.0";
  }