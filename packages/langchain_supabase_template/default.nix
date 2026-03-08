{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      langchain
      langchain-community
      langchain-openai
      pytest
    ]
  );
in
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.nodejs
    pythonEnv
    supabase-cli
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pythonEnv}/bin/python $out/lib/${pname}/app/main.py" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.nodejs
          pythonEnv
          supabase-cli
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "langchain_supabase_template";
  src = ./.;
  version = "0.0.0";
}
