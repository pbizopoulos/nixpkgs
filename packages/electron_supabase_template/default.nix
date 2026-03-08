{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.buildNpmPackage rec {
  buildInputs = [
    pkgs.nodejs
    pkgs.electron
    supabase-cli
  ];
  env = {
    SUPABASE_URL = "http://localhost:54321";
    SUPABASE_ANON_KEY = "build-placeholder";
  };
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  npmDepsHash = "sha256-0000000000000000000000000000000000000000000=";
  pname = "electron_supabase_template";
  src = ./.;
  version = "0.0.0";
}
