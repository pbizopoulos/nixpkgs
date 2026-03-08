{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.buildNpmPackage rec {
  buildInputs = [
    pkgs.nodejs
    supabase-cli
  ];
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  npmDepsHash = "sha256-0000000000000000000000000000000000000000000=";
  pname = "react_native_supabase_template";
  src = ./.;
  version = "0.0.0";
}
