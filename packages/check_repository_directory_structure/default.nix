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
    pkgs.clippy
    pkgs.git
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf ./.;
  postInstall = ''
    cargo clippy -- -D warnings
    DEBUG=1 $out/bin/${pname}
  '';
  src = ./.;
  version = "0.0.0";
}
