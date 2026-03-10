{
  pkgs ? import <nixpkgs> { },
  postgresql ? pkgs.postgresql,
}:
let
  rubyEnv = pkgs.ruby.withPackages (ps: with ps; [ sinatra ]);
in
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
    rubyEnv
    postgresql
  ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Checking dependencies for smoke test..."; postgres --version; node --version; echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${rubyEnv}/bin/ruby $out/lib/${pname}/app/app.rb -o 0.0.0.0" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          rubyEnv
          postgresql
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "sinatra_postgres_template";
  src = ./.;
  version = "0.0.0";
}
