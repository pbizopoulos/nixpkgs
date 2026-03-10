{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      pkgs.bundler
      pkgs.gcc
      pkgs.gnumake
      pkgs.makeWrapper
      pkgs.nodejs
      pkgs.ruby
      pkgs.sqlite
      postgresql
    ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -rL . $out/lib/node_modules/${pname}
      mkdir -p $out/bin
      cp $out/lib/node_modules/${pname}/scripts/start.js $out/bin/${pname}
      chmod +x $out/bin/${pname}
      wrapProgram $out/bin/${pname} \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.bundler
        pkgs.gcc
        pkgs.gnumake
        pkgs.nodejs
        pkgs.ruby
        pkgs.sqlite
        postgresql
      ]}
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "rails_postgres_template";
    src = ./.;
    version = "0.0.0";
  }
