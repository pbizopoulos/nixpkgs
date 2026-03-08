{ pkgs ? import <nixpkgs> { }
,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.nodejs
    pkgs.makeWrapper
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules/${pname}
    cp -rL . $out/lib/node_modules/${pname}
    mkdir -p $out/bin
    cp $out/lib/node_modules/${pname}/scripts/start.js $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "solidstart_supabase_template";
  src = ./.;
  version = "0.0.0";
}
