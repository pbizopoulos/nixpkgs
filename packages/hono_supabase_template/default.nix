{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.nodejs
    supabase-cli
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -rL . $out/lib/node_modules/${pname}
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
      --set SUPABASE_URL "http://localhost:54321" \
      --set SUPABASE_ANON_KEY "build-placeholder" \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pkgs.supabase-cli
        ]
      } \
      --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs}" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "hono_supabase_template";
  src = ./.;
  version = "0.0.0";
}
