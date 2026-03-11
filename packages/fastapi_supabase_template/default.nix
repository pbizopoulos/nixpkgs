{
  pkgs ? import <nixpkgs> { },
  supabaseCli ? pkgs.supabase-cli,
}:
let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      fastapi
      httpx
      pytest
      pytest-playwright
      uvicorn
    ]
  );
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
    supabaseCli
    pythonEnv
  ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -rL . $out/lib/node_modules/${pname}
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pkgs.supabase-cli
          pythonEnv
        ]
      } \
      --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs}" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "fastapi_supabase_template";
  src = ./.;
  version = "0.0.0";
}
