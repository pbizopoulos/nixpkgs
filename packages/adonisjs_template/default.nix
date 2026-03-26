{
  inputs,
  pkgs ? import <nixpkgs> { },
}:
let
  installationScript = inputs.agenix-shell.lib.installationScript pkgs.stdenv.system {
    secrets.secrets.file = ../../secrets/secrets.age;
  };
in
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
  npmDepsHash = "sha256-mH39hezfMd8CFjE6WxAd1qvy/0ngmXSlXGiaAjgEIyg=";
  npmFlags = [
    "--legacy-peer-deps"
  ];
  pname = baseNameOf ./.;
  shellHook = ''
    # shellcheck disable=SC1091
    source ${pkgs.lib.getExe installationScript}
    export $(grep -v '^#' "$secrets_PATH" | xargs)
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PGDATA="''${PGDATA:-$PWD/tmp/.postgres}"
    export PGHOST="''${PGHOST:-/tmp/adonisjs-template-pg}"
    export PGPORT="''${PGPORT:-5432}"
    export PGUSER="''${PGUSER:-postgres}"
    export PGPASSWORD="''${PGPASSWORD:-postgres}"
    export PGDATABASE="''${PGDATABASE:-adonisjs_template}"
    export DB_HOST="''${DB_HOST:-$PGHOST}"
    export DB_PORT="''${DB_PORT:-$PGPORT}"
    export DB_USER="''${DB_USER:-$PGUSER}"
    export DB_PASSWORD="''${DB_PASSWORD:-$PGPASSWORD}"
    export DB_DATABASE="''${DB_DATABASE:-$PGDATABASE}"
    export DB_SSL="''${DB_SSL:-false}"
    export DATABASE_URL="postgres://''${PGUSER}:''${PGPASSWORD}@/''${PGDATABASE}?host=''${PGHOST}&port=''${PGPORT}"
  '';
  src = ./.;
  version = "0.0.0";
}
