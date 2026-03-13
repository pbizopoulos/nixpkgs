{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildNpmPackage rec {
  nativeBuildInputs = [
    pkgs.supabase-cli
    pkgs.openssl
    pkgs.makeWrapper
  ];
  npmDepsHash = "sha256-icIIG7nHct4SYZubYOwc37RtwcTgW/0CYCU4LTO9iv4=";
  meta.mainProgram = pname;
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
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}/
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags "$out/lib/node_modules/${pname}/scripts/start.js" \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pkgs.nodePackages.npm
          pkgs.supabase-cli
          pkgs.git
          pkgs.openssl
        ]
      } \
      --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} \
      --set NEXT_PUBLIC_SUPABASE_URL "http://localhost:54321" \
      --set NEXT_PUBLIC_SUPABASE_ANON_KEY "build-placeholder"
    runHook postInstall
  '';
  shellHook = ''
    export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
  '';
  src = ./.;
  version = "0.0.0";
}
