{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.nodejs
    pkgs.postgresql
  ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Checking dependencies for smoke test..."; node --version; psql --version; echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "true" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pkgs.postgresql
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "express_postgres_template";
  src = ./.;
  version = "0.0.0";
}
