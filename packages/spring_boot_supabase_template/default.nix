{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
    pkgs.jdk17
    pkgs.gradle
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
    echo "exec java -jar $out/lib/${pname}/build/libs/*.jar" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} 
      --set PLAYWRIGHT_BROWSERS_PATH ${pkgs.playwright-driver.browsers} 
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pkgs.jdk17
          supabase-cli
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  pname = "spring_boot_supabase_template";
  shellHook = ''
    export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
  '';
  src = ./.;
  version = "0.0.0";
}
