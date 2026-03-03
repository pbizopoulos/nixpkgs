{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) rustPlatform;
in
rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-J32X5kYjZEhl6ooSBGuVdrDyiX1EjlpJDA/WELke2ZE=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.pkg-config
    rustPlatform.bindgenHook
  ];
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.1.0";
}
