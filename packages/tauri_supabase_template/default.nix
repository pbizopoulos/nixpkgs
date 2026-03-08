{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.buildNpmPackage rec {
  buildInputs = [
    pkgs.nodejs
    pkgs.rustc
    pkgs.cargo
    pkgs.pkg-config
    pkgs.openssl
    pkgs.librsvg
    pkgs.webkitgtk_4_1
    supabase-cli
  ];
  env = {
    SUPABASE_URL = "http://localhost:54321";
    SUPABASE_ANON_KEY = "build-placeholder";
  };
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.pkg-config
    pkgs.openssl
    supabase-cli
  ];
  npmDepsHash = "sha256-0000000000000000000000000000000000000000000=";
  pname = "tauri_supabase_template";
  src = ./.;
  version = "0.0.0";
}
