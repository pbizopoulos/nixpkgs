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
      (stdenv.cc)
    ];
    dev_libraries = map (l:
      l.dev or l) libraries;
    libraries = with pkgs;
    [
      alsa-lib
      libX11
      libXcursor
      libXi
      libXrandr
      libxkbcommon
      openssl
      udev
      vulkan-loader
      wayland
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
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath libraries}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "bevy_postgres_template";
    src = ./.;
    version = "0.0.0";
  }