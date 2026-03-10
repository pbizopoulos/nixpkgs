{
  pkgs ? import <nixpkgs> { },
  postgresql ? pkgs.postgresql,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.alsa-lib
    pkgs.cargo
    pkgs.libX11
    pkgs.libXcursor
    pkgs.libXi
    pkgs.libXrandr
    pkgs.libxkbcommon
    pkgs.rustc
    pkgs.udev
    pkgs.vulkan-loader
    pkgs.wayland
    postgresql
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
          pkgs.alsa-lib
          pkgs.cargo
          pkgs.libX11
          pkgs.libXcursor
          pkgs.libXi
          pkgs.libXrandr
          pkgs.libxkbcommon
          pkgs.nodejs
          pkgs.postgresql
          pkgs.rustc
          pkgs.stdenv.cc
          pkgs.udev
          pkgs.vulkan-loader
          pkgs.wayland
        ]
      } \
      --prefix PKG_CONFIG_PATH : "${
        pkgs.lib.makeSearchPath "lib/pkgconfig" (
          buildInputs
          ++ [
            pkgs.alsa-lib
            pkgs.libX11
            pkgs.libXcursor
            pkgs.libXi
            pkgs.libXrandr
            pkgs.libxkbcommon
            pkgs.udev
            pkgs.vulkan-loader
            pkgs.wayland
          ]
        )
      }" \
      --prefix LD_LIBRARY_PATH : "${
        pkgs.lib.makeLibraryPath (
          buildInputs
          ++ [
            pkgs.alsa-lib
            pkgs.libX11
            pkgs.libXcursor
            pkgs.libXi
            pkgs.libXrandr
            pkgs.libxkbcommon
            pkgs.udev
            pkgs.vulkan-loader
            pkgs.wayland
          ]
        )
      }"
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.pkg-config
    postgresql
  ];
  pname = "ply_engine_postgres_template";
  src = ./.;
  version = "0.0.0";
}
