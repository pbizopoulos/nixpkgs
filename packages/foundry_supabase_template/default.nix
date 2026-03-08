{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
let
  inherit (pkgs) stdenv;
in
stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.foundry-bin
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
  pname = "foundry_supabase_template";
  src = ./.;
  version = "0.0.0";
}
