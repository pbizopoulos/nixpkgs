{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildNpmPackage {
  buildInputs = [ pkgs.nodejs ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/typescript
    cp -r . $out/lib/node_modules/typescript
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/typescript \
      --add-flags "$out/lib/node_modules/typescript/dist/main.js"
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  npmDepsHash = "sha256-dBs6X0cMNfo86FsK4lzcC07zCTo7mBfOZWZ8mL+QYAI=";
  pname = "typescript";
  src = ./.;
  version = "0.0.0";
}
