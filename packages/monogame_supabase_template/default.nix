{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.dotnet-sdk_9
    pkgs.SDL2
    pkgs.openal
    pkgs.libGL
    supabase-cli
  ];
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
          pkgs.pkg-config
          pkgs.makeWrapper
          pkgs.dotnet-sdk_9
        ]
      } \
      --prefix PKG_CONFIG_PATH : "${
        pkgs.lib.makeSearchPath "lib/pkgconfig" (
          buildInputs
          ++ [
            pkgs.SDL2
            pkgs.openal
            pkgs.libGL
          ]
        )
      }" \
      --prefix LD_LIBRARY_PATH : "${
        pkgs.lib.makeLibraryPath (
          buildInputs
          ++ [
            pkgs.SDL2
            pkgs.openal
            pkgs.libGL
          ]
        )
      }"
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  pname = "monogame_supabase_template";
  src = ./.;
  version = "0.0.0";
}
