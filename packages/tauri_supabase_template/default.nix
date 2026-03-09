{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
let
  libraries = with pkgs; [
    webkitgtk_4_1
    gtk3
    libsoup_3
    libayatana-appindicator
    librsvg
    gdk-pixbuf
    glib
    pango
    cairo
    openssl
    dbus
    atk
    fontconfig
    freetype
    harfbuzz
    zlib
    at-spi2-atk
    at-spi2-core
    libX11
    libXext
    libXi
    libXrandr
    libXcursor
    libXfixes
    libXcomposite
    libXdamage
    libXinerama
    wayland
    libxkbcommon
    libepoxy
    fribidi
  ];
  dev_libraries = map (l: l.dev or l) libraries;
  build_deps = with pkgs; [
    nodejs
    supabase-cli
    pkg-config
    makeWrapper
    cargo
    rustc
    stdenv.cc
  ];
in
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = libraries ++ build_deps;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -rL . $out/lib/node_modules/${pname}
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
      --prefix PATH : ${pkgs.lib.makeBinPath build_deps} \
      --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" dev_libraries}" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath libraries}"
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "tauri_supabase_template";
  src = ./.;
  version = "0.0.0";
}
