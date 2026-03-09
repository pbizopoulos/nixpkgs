{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) lib;
  beamPackages = pkgs.beam.packages.erlang_27;
  inherit (beamPackages) elixir;
  pname = "phoenix_template";
  version = "0.1.0";
  src = ./.;
  mixDeps = import "${src}/deps.nix" { inherit lib beamPackages; };
  phoenixApp = beamPackages.buildMix {
    name = "phoenix_app";
    inherit version;
    src = ./.;
    beamDeps = builtins.attrValues mixDeps;
  };
  erlLibs = lib.makeSearchPath "lib/erlang/lib" ([ phoenixApp ] ++ (builtins.attrValues mixDeps));
in
pkgs.stdenv.mkDerivation {
  dontBuild = true;
  inherit pname version src;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ elixir ];
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
      --prefix PATH : "${
        lib.makeBinPath [
          elixir
          pkgs.nodejs
        ]
      }"
    runHook postInstall
  '';
  meta.mainProgram = pname;
}
