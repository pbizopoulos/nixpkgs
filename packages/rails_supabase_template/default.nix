{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.bundler
    pkgs.gcc
    pkgs.gnumake
    pkgs.makeWrapper
    pkgs.nodejs
    pkgs.ruby
    pkgs.sqlite
  ];
  dontBuild = true;
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
          pkgs.bundler
          pkgs.gcc
          pkgs.gnumake
          pkgs.nodejs
          pkgs.ruby
          pkgs.sqlite
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "rails_supabase_template";
  src = ./.;
  version = "0.0.0";
}
