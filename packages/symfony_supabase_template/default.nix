{ pkgs ? import <nixpkgs> {}
  , supabaseCli ? pkgs.supabase-cli }:
  let
    phpEnv = pkgs.php.withExtensions ({ all
      , enabled }:
      enabled ++ [
        all.pdo_pgsql
        all.pgsql
      ]);
  in pkgs.stdenv.mkDerivation rec {
    buildInputs = [
      phpEnv
      pkgs.nodejs
      pkgs.php.packages.composer
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
        phpEnv
        pkgs.nodejs
        pkgs.php.packages.composer
        pkgs.supabase-cli
      ]} \
        --prefix PKG_CONFIG_PATH : "${pkgs.lib.makeSearchPath "lib/pkgconfig" buildInputs}" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}"
      runHook postInstall
      '';
    nativeBuildInputs = [
      pkgs.makeWrapper
    ];
    pname = "symfony_supabase_template";
    src = ./.;
    version = "0.0.0";
  }
