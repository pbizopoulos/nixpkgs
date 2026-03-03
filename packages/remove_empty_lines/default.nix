{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-aT64u3Tqrk+XXPptAtVs2EnVeOU2NCwSHg1XYeadZHs=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = builtins.baseNameOf src;
  src = ./.;
  version = "0.1.0";
}
