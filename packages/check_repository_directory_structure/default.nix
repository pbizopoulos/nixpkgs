{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-R3cJZIt3pbFznqQzl4dIlehqwPdeYyqN1yy8M6WftMc=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
