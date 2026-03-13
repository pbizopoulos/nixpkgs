{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-R3cJZIt3pbFznqQzl4dIlehqwPdeYyqN1yy8M6WftMc=";
  nativeBuildInputs = [
    pkgs.git
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.1.0";
}
