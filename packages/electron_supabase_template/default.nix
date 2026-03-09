{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.nodejs
    pkgs.makeWrapper
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
        ]
      } \
      --prefix PKG_CONFIG_PATH : "${
        pkgs.lib.makeSearchPath "lib/pkgconfig" (
          buildInputs
          ++ [
            pkgs.gtk3
            pkgs.nss
            pkgs.nspr
            pkgs.dbus
            pkgs.atk
            pkgs.cups
            pkgs.libdrm
            pkgs.libX11
            pkgs.libXcomposite
            pkgs.libXdamage
            pkgs.libXext
            pkgs.libXfixes
            pkgs.libXrandr
            pkgs.libgbm
            pkgs.expat
            pkgs.pango
            pkgs.cairo
            pkgs.alsa-lib
            pkgs.at-spi2-atk
            pkgs.at-spi2-core
            pkgs.libxshmfence
            pkgs.mesa
            pkgs.libGL
          ]
        )
      }" \
      --prefix LD_LIBRARY_PATH : "${
        pkgs.lib.makeLibraryPath (
          buildInputs
          ++ [
            pkgs.gtk3
            pkgs.nss
            pkgs.nspr
            pkgs.dbus
            pkgs.atk
            pkgs.cups
            pkgs.libdrm
            pkgs.libX11
            pkgs.libXcomposite
            pkgs.libXdamage
            pkgs.libXext
            pkgs.libXfixes
            pkgs.libXrandr
            pkgs.libgbm
            pkgs.expat
            pkgs.pango
            pkgs.cairo
            pkgs.alsa-lib
            pkgs.at-spi2-atk
            pkgs.at-spi2-core
            pkgs.libxshmfence
            pkgs.mesa
            pkgs.libGL
          ]
        )
      }"
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "electron_supabase_template";
  src = ./.;
  version = "0.0.0";
}
