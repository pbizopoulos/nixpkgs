{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
let
  inherit (pkgs) rustPlatform;
in
rustPlatform.buildRustPackage rec {
  buildInputs = [
    pkgs.udev
    pkgs.alsa-lib
    pkgs.vulkan-loader
    pkgs.libxkbcommon
    pkgs.wayland
    pkgs.xorg.libX11
    pkgs.xorg.libXcursor
    pkgs.xorg.libXi
    pkgs.xorg.libXrandr
    supabase-cli
  ];
  cargoHash = "sha256-0000000000000000000000000000000000000000000=";
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.pkg-config
    supabase-cli
  ];
  pname = "ply_engine_supabase_template";
  src = ./.;
  version = "0.0.0";
}
