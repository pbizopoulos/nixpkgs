{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.SDL2
      pkgs.dotnet-sdk_9
      pkgs.libGL
      pkgs.openal
      postgresql
    ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -rL . $out/lib/node_modules/${pname}
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
        --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.SDL2
        pkgs.dotnet-sdk_9
        pkgs.libGL
        pkgs.nodejs
        pkgs.openal
        pkgs.postgresql
      ]} \
        --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" (buildInputs ++ [
        pkgs.SDL2
        pkgs.libGL
        pkgs.openal
      ])}" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath (buildInputs ++ [
        pkgs.SDL2
        pkgs.libGL
        pkgs.openal
      ])}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
      postgresql
    ];
    pname = "monogame_postgres_template";
    src = ./.;
    version = "0.0.0";
  }
