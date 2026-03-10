{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.makeWrapper
      pkgs.nodejs
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
        pkgs.nodejs
        pkgs.postgresql
      ]} \
        --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs}" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "react_native_postgres_template";
    src = ./.;
    version = "0.0.0";
  }
