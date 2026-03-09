{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
let
  phpEnv = pkgs.php.withExtensions (
    { all, enabled }:
    enabled
    ++ [
      all.pdo_pgsql
      all.pgsql
    ]
  );
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    phpEnv
    pkgs.nodejs
    supabase-cli
  ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${phpEnv}/bin/php $out/lib/${pname}/app/public/index.php" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          phpEnv
          pkgs.nodejs
          supabase-cli
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "symfony_supabase_template";
  src = ./.;
  version = "0.0.0";
}
