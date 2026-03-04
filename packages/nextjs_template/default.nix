{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
pkgs.buildNpmPackage rec {
  buildInputs = [
    pkgs.nodejs
    supabase-cli
  ];
  env = {
    NEXT_PUBLIC_SUPABASE_ANON_KEY = "build-placeholder";
    NEXT_PUBLIC_SUPABASE_URL = "http://localhost:54321";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/${pname}/scripts/start.js $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} \
      --set PKG_CONFIG_PATH ${pkgs.openssl.dev}/lib/pkgconfig \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          supabase-cli
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.openssl
    supabase-cli
  ];
  npmDepsHash = "sha256-KG3LBerWYS0/Lp6ZKNa8lCmKAlOB0OeDv4oDjozc7Y8=";
  pname = baseNameOf src;
  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
  '';
  src = ./.;
  version = "0.0.0";
}
