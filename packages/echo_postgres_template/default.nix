{ pkgs ? import <nixpkgs> {}
  , postgresql ? pkgs.postgresql }:
  pkgs.buildGoModule rec {
    buildInputs = [
      (pkgs.nodejs)
      postgresql
    ];
    env.CGO_ENABLED = "0";
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/${pname}
      cp -rL . $out/lib/${pname}
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Checking dependencies for smoke test..."; postgres --version; node --version; echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
      echo "exec $out/bin/echo_postgres_template" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
      wrapProgram $out/bin/${pname} \
        --prefix PATH : ${pkgs.lib.makeBinPath [
        (pkgs.nodejs)
        postgresql
      ]}
      runHook postInstall
      '';
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
    pname = "echo_postgres_template";
    src = ./.;
    vendorHash = null;
    version = "0.0.0";
  }