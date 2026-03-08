{ pkgs ? import <nixpkgs> { }
,
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
  inherit pname version src;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ elixir ];
  installPhase = ''
    runHook preInstall
        mkdir -p $out/lib/${pname}
        cp -r . $out/lib/${pname}
        chmod +x $out/lib/${pname}/scripts/start.js
        mkdir -p $out/bin
        ln -s $out/lib/${pname}/scripts/start.js $out/bin/${pname}
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
