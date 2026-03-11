{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildNpmPackage rec {
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.openssl
    pkgs.supabase-cli
  ];
  buildInputs = [
    pkgs.nodejs
    pkgs.supabase-cli
  ];
  npmDepsHash = "sha256-KG3LBerWYS0/Lp6ZKNa8lCmKAlOB0OeDv4oDjozc7Y8=";
  pname = "nextjs-supabase";
  env = {
    NEXT_PUBLIC_SUPABASE_URL = "http://localhost:54321";
    NEXT_PUBLIC_SUPABASE_ANON_KEY = "build-placeholder";
  };
  preBuild = ''
    cp "${
      pkgs.google-fonts.override { fonts = [ "Inter" ]; }
    }/share/fonts/truetype/Inter[opsz,wght].ttf" app/Inter.ttf
    cp "${
      pkgs.google-fonts.override { fonts = [ "RobotoMono" ]; }
    }/share/fonts/truetype/RobotoMono[wght].ttf" app/RobotoMono.ttf
  '';
  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
  '';
  src = ./.;
  version = "0.0.0";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/nextjs-supabase
    cp -r . $out/lib/node_modules/nextjs-supabase
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/nextjs-supabase/scripts/start.js $out/bin/nextjs-supabase
    wrapProgram $out/bin/nextjs-supabase \
      --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} \
      --set PKG_CONFIG_PATH ${pkgs.openssl.dev}/lib/pkgconfig \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pkgs.supabase-cli
        ]
      }
    runHook postInstall
  '';
}
