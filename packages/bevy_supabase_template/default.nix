{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.udev
    pkgs.alsa-lib
    pkgs.vulkan-loader
    pkgs.libxkbcommon
    pkgs.wayland
    pkgs.libX11
    pkgs.libXcursor
    pkgs.libXi
    pkgs.libXrandr
    pkgs.rustc
    pkgs.cargo
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
          pkgs.cargo
          pkgs.rustc
          pkgs.stdenv.cc
        ]
      } \
      --prefix PKG_CONFIG_PATH : "${
        pkgs.lib.makeSearchPath "lib/pkgconfig" (
          buildInputs
          ++ [
            pkgs.udev
            pkgs.alsa-lib
            pkgs.vulkan-loader
            pkgs.libxkbcommon
            pkgs.wayland
            pkgs.libX11
            pkgs.libXcursor
            pkgs.libXi
            pkgs.libXrandr
          ]
        )
      }" \
      --prefix LD_LIBRARY_PATH : "${
        pkgs.lib.makeLibraryPath (
          buildInputs
          ++ [
            pkgs.udev
            pkgs.alsa-lib
            pkgs.vulkan-loader
            pkgs.libxkbcommon
            pkgs.wayland
            pkgs.libX11
            pkgs.libXcursor
            pkgs.libXi
            pkgs.libXrandr
          ]
        )
      }"
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.pkg-config
    supabase-cli
  ];
  pname = "bevy_supabase_template";
  src = ./.;
  version = "0.0.0";
}
