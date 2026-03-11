{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildNpmPackage {
  nativeBuildInputs = [
    pkgs.supabase-cli
    pkgs.openssl
  ];
  npmDepsHash = "sha256-icIIG7nHct4SYZubYOwc37RtwcTgW/0CYCU4LTO9iv4=";
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
}
