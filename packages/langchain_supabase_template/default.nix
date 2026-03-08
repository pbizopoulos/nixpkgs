{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    langchain
    langchain-community
    langchain-openai
    supabase
    pytest
  ]);
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
    pythonEnv
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
  pname = "langchain_supabase_template";
  src = ./.;
  version = "0.0.0";
}
