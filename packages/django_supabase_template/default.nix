{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    django
    django-cors-headers
    supabase
    pytest
    pytest-django
    pytest-playwright
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
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -r . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo "exec ${pythonEnv}/bin/python $out/lib/${pname}/manage.py runserver" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} 
      --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} 
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pythonEnv
          supabase-cli
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  pname = "django_supabase_template";
  shellHook = ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
  '';
  src = ./.;
  version = "0.0.0";
}
