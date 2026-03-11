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
  npmDepsHash = "sha256-PYHvoR6lfkMxP4m4ku7LhXn4KNwVDCGZ2njBrTSC3BE=";
  pname = baseNameOf ./.;
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
    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}
    mkdir -p $out/bin
    wrapProgram $out/bin/${pname} \
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
