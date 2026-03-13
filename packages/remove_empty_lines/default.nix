{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-+zw72kFphEKceFEgjcZn8uHsVWTz38pNXgOIzvFn9cY=";
  env.RUSTFLAGS = "-D warnings";
  meta.mainProgram = pname;
  nativeBuildInputs = [
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
