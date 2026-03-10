{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.nodejs
      postgresql
    ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -rL . $out/lib/node_modules/${pname}
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
        --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
        --set POSTGRES_URL "http://localhost:54321" \
        --set POSTGRES_ANON_KEY "build-placeholder" \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.nodejs
        pkgs.postgresql
      ]} \
        --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs}" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "express_postgres_template";
    src = ./.;
    version = "0.0.0";
  }
