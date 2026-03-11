{ pkgs ? import <nixpkgs> {}
  , supabaseCli ? pkgs.supabase-cli }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.cargo
      pkgs.rustc
      supabaseCli
    ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -rL . $out/lib/node_modules/${pname}
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
        --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.cargo
        pkgs.nodejs
        pkgs.supabase-cli
        pkgs.rustc
        pkgs.stdenv.cc
      ]}
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "leptos_template";
    src = ./.;
    version = "0.0.0";
  }
