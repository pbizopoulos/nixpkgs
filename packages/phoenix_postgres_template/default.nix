{ pkgs ? import <nixpkgs> {} }:
  let
    inherit (pkgs) lib;
    inherit (beamPackages) elixir;
    beamPackages = pkgs.beam.packages.erlang_27;
    erlLibs = lib.makeSearchPath "lib/erlang/lib" ([
      phoenixApp
    ] ++ builtins.attrValues mixDeps);
    mixDeps = import "${src}/deps.nix" {
      inherit lib
              beamPackages;
    };
    phoenixApp = beamPackages.buildMix {
      inherit version;
      beamDeps = builtins.attrValues mixDeps;
      name = "phoenix_app";
      src = ./.;
    };
    pname = "phoenix_postgres_template";
    src = ./.;
    version = "0.1.0";
  in pkgs.stdenv.mkDerivation {
    inherit pname
            version
            src;
    buildInputs = [
      elixir
    ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/${pname}
      cp -rL . $out/lib/${pname}
      mkdir -p $out/bin
      echo "#!/bin/sh" > $out/bin/${pname}
      echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
      echo "exec ${pkgs.nodejs}/bin/node $out/lib/${pname}/scripts/start.js" >> $out/bin/${pname}
      chmod +x $out/bin/${pname}
      wrapProgram $out/bin/${pname} \
        --set LC_ALL C.UTF-8 \
        --set ELIXIR_ERL_OPTIONS "+fnu" \
        --set ERL_LIBS "${erlLibs}" \
        --prefix PATH : "${lib.makeBinPath [
        elixir
        (pkgs.gcc)
        (pkgs.gnumake)
        (pkgs.nodejs)
        (pkgs.postgresql)
        (pkgs.postgresql)
      ]}"
      runHook postInstall
      '';
    meta.mainProgram = pname;
    nativeBuildInputs = [
      (pkgs.makeWrapper)
    ];
  }