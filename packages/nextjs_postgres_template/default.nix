{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.buildNpmPackage rec {
    buildInputs = [
      pkgs.nodejs
      postgresql
    ];
    env = {
      NEXT_PUBLIC_POSTGRES_ANON_KEY = "build-placeholder";
      NEXT_PUBLIC_POSTGRES_URL = "http://localhost:54321";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -r . $out/lib/node_modules/${pname}
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
        --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
        --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} \
        --set PKG_CONFIG_PATH ${pkgs.openssl.dev}/lib/pkgconfig \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.nodejs
        postgresql
      ]}
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.openssl
      postgresql
    ];
    npmDepsHash = "sha256-MLlE686f3E98i3UAmTGOBChSHloK2SbNiXoteGFmZ3U=";
    pname = "nextjs_postgres_template";
    shellHook = ''
      export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
      export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
      '';
    src = ./.;
    version = "0.0.0";
  }
