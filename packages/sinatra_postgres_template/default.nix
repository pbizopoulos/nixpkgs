{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      (pkgs.bundler)
      (pkgs.nodejs)
      (pkgs.ruby)
      postgresql
    ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/${pname}
      cp -rL . $out/lib/node_modules/${pname}
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} \
        --add-flags $out/lib/node_modules/${pname}/scripts/start.js \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        (pkgs.bundler)
        (pkgs.gcc)
        (pkgs.gnumake)
        (pkgs.nodejs)
        (pkgs.ruby)
        postgresql
      ]}
      runHook postInstall
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "sinatra_postgres_template";
    src = ./.;
    version = "0.0.0";
  }