{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildNpmPackage rec {
  buildInputs = [ ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}/
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags "$out/lib/node_modules/${pname}/scripts/start.js" \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.git
          pkgs.nodePackages.npm
          pkgs.nodejs
          pkgs.openssl
          pkgs.postgresql
        ]
      } \
      --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers}
    runHook postInstall
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.openssl
    pkgs.postgresql
  ];
  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-i00FXU6+TUDR1kFPubv8hD0vR9OqwFGfxOnp1gcpvIw=";
  npmFlags = [
    "--legacy-peer-deps"
  ];
  pname = baseNameOf ./.;
  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PGDATA="$PWD/tmp/.postgres"
    export PGHOST="/tmp/adonisjs-template-pg"
    export PGPORT="5432"
    export PGUSER="postgres"
    export PGPASSWORD="postgres"
    export PGDATABASE="adonisjs_template"
    export DB_HOST="$PGHOST"
    export DB_PORT="$PGPORT"
    export DB_USER="$PGUSER"
    export DB_PASSWORD="$PGPASSWORD"
    export DB_DATABASE="$PGDATABASE"
    export DB_SSL="false"
    export DATABASE_URL="postgres://''${PGUSER}:''${PGPASSWORD}@/''${PGDATABASE}?host=''${PGHOST}&port=''${PGPORT}"
  '';
  src = ./.;
  version = "0.0.0";
}
