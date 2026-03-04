{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  buildInputs = [ ];
  cargoHash = "sha256-/9P6dTTwhBnzLMY7LgS4Me+gVZWM9CZ7glPg8Q9P76M=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  pname = baseNameOf src;
  src = ./.;
  version = "0.1.0";
}
