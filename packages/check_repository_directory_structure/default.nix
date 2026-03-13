{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.openssl
    pkgs.zlib
  ];
  cargoHash = "sha256-R3cJZIt3pbFznqQzl4dIlehqwPdeYyqN1yy8M6WftMc=";
  env.RUSTFLAGS = "-D warnings";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.git
    pkgs.clippy
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  postInstall = ''
    cargo clippy -- -D warnings
    cargo test
    DEBUG=1 $out/bin/${pname}
  '';
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
