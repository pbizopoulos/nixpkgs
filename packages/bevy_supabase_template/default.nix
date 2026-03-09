{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
let
  libraries = with pkgs; [
    udev
    alsa-lib
    vulkan-loader
    libxkbcommon
    wayland
    libX11
    libXcursor
    libXi
    libXrandr
    openssl
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
  pname = "bevy_supabase_template";
  src = ./.;
  version = "0.0.0";
}
