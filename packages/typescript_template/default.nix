{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.buildNpmPackage rec {
  buildInputs = [ pkgs.nodejs ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags "$out/lib/node_modules/${pname}/dist/main.js"
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  npmDepsHash = "sha256-dBs6X0cMNfo86FsK4lzcC07zCTo7mBfOZWZ8mL+QYAI=";
  pname = "typescript_template";
  src = ./.;
  version = "0.0.0";
}
