{
  pkgs ? import <nixpkgs> { },
  supabase-cli ? pkgs.supabase-cli,
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.dotnet-sdk
    pkgs.nodejs
    supabase-cli
  ];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.dotnet-sdk}/bin/dotnet run --project $out/lib/${pname}/app" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.dotnet-sdk
          pkgs.nodejs
          supabase-cli
        ]
      }
    runHook postInstall
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "dotnet_supabase_template";
  src = ./.;
  version = "0.0.0";
}
