{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.dotnet-sdk_9
    pkgs.SDL2
    pkgs.openal
    pkgs.libGL
    supabase-cli
  ];
  env = {
    SUPABASE_URL = "http://localhost:54321";
    SUPABASE_ANON_KEY = "build-placeholder";
  };
  installPhase = ''
    mkdir -p $out/lib/${pname}
    cp -r out/* $out/lib/${pname}/
    mkdir -p $out/bin
    makeWrapper ${pkgs.dotnet-runtime_9}/bin/dotnet $out/bin/${pname} 
      --add-flags "$out/lib/${pname}/${pname}.dll" 
      --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath [ pkgs.SDL2 pkgs.openal pkgs.libGL ]}"
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  pname = "monogame_supabase_template";
  src = ./.;
  version = "0.0.0";
}
