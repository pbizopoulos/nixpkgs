{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  let
    build_deps = with pkgs;
    [
      cargo
      makeWrapper
      nodejs
      pkg-config
      postgresql
      rustc
      stdenv.cc
    ];
    dev_libraries = map (l:
      l.dev or l) libraries;
    libraries = with pkgs;
    [
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      dbus
      fontconfig
      freetype
      fribidi
      gdk-pixbuf
      glib
      gtk3
      harfbuzz
      libX11
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXinerama
      libXrandr
      libayatana-appindicator
      libepoxy
      librsvg
      libsoup_3
      libxkbcommon
      openssl
      pango
      wayland
      webkitgtk_4_1
      zlib
    ];
  in pkgs.stdenv.mkDerivation rec {
    buildInputs = libraries ++ build_deps;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -rL . $out/lib/node_modules/${pname}
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
        --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
        --prefix PATH : ${pkgs.lib.makeBinPath build_deps} \
        --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" dev_libraries}" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath libraries}" \
        --prefix LIBRARY_PATH : "${pkgs.lib.makeLibraryPath libraries}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "tauri_postgres_template";
    src = ./.;
    version = "0.0.0";
  }
