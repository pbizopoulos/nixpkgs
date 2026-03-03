{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) rustPlatform;
in

rustPlatform.buildRustPackage rec {
  pname = "check_repository_directory_structure";
  version = "0.1.0";
  src = ./.;
  nativeBuildInputs = [
    pkgs.git
    rustPlatform.bindgenHook
    pkgs.pkg-config
  ];
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-J32X5kYjZEhl6ooSBGuVdrDyiX1EjlpJDA/WELke2ZE=";
}
