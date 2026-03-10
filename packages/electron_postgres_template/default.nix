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
        --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" (buildInputs ++ [
        pkgs.alsa-lib
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.atk
        pkgs.cairo
        pkgs.cups
        pkgs.dbus
        pkgs.expat
        pkgs.gtk3
        pkgs.libGL
        pkgs.libX11
        pkgs.libXcomposite
        pkgs.libXdamage
        pkgs.libXext
        pkgs.libXfixes
        pkgs.libXrandr
        pkgs.libdrm
        pkgs.libgbm
        pkgs.libxshmfence
        pkgs.mesa
        pkgs.nspr
        pkgs.nss
        pkgs.pango
      ])}" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath (buildInputs ++ [
        pkgs.alsa-lib
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.atk
        pkgs.cairo
        pkgs.cups
        pkgs.dbus
        pkgs.expat
        pkgs.gtk3
        pkgs.libGL
        pkgs.libX11
        pkgs.libXcomposite
        pkgs.libXdamage
        pkgs.libXext
        pkgs.libXfixes
        pkgs.libXrandr
        pkgs.libdrm
        pkgs.libgbm
        pkgs.libxshmfence
        pkgs.mesa
        pkgs.nspr
        pkgs.nss
        pkgs.pango
      ])}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "electron_postgres_template";
    src = ./.;
    version = "0.0.0";
  }
