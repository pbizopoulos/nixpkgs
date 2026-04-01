{
  inputs,
  pkgs ? import <nixpkgs> { },
}:
let
  installationScript = inputs.agenix-shell.lib.installationScript pkgs.stdenv.system {
    secrets.secrets.file = ../../secrets/secrets.age;
  };
  pname = baseNameOf ./.;
  runtimePath = pkgs.lib.makeBinPath [
    pkgs.bash
    pkgs.git
    pkgs.nodejs
    pkgs.openssl
    pkgs.postgresql
  ];
in
pkgs.buildNpmPackage {
  inherit pname;
  dontNpmPrune = true;
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.openssl
    pkgs.postgresql
  ];
  npmDepsHash = "sha256-BaqM4vUcLOlzeU/tJOPQ9uTD7nb8khwYrjWIkE9NpA8=";
  postInstall = ''
    cp -r build "$out/lib/node_modules/${pname}/build"
    mkdir -p "$out/lib/node_modules/${pname}/public"
    cp -r public/assets "$out/lib/node_modules/${pname}/public/assets"
  '';
  postPatch = ''
    substituteInPlace bin/entrypoint.js \
      --replace-fail "@packagedRuntimePath@" "${runtimePath}" \
      --replace-fail "@packagedPlaywrightBrowsersPath@" "${pkgs.playwright-driver.browsers}" \
      --replace-fail "@packagedChromiumExecutablePath@" "${pkgs.lib.getExe pkgs.chromium}"
  '';
  shellHook = ''
    # shellcheck disable=SC1091
    source ${pkgs.lib.getExe installationScript}
    export $(grep -v '^#' "$secrets_PATH" | xargs)
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
    export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=${pkgs.lib.getExe pkgs.chromium}
    export PGDATA="''${PGDATA:-$PWD/tmp/.postgres}"
    export PGHOST="''${PGHOST:-/tmp/adonisjs-template-pg}"
    export PGPORT="''${PGPORT:-5432}"
    export PGUSER="''${PGUSER:-postgres}"
    export PGPASSWORD="''${PGPASSWORD:-postgres}"
    export PGDATABASE="''${PGDATABASE:-${pname}}"
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
