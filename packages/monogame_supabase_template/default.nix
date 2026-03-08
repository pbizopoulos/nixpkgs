{ pkgs ? import <nixpkgs> { }
, supabase-cli ? pkgs.supabase-cli
,
}:
pkgs.stdenv.mkDerivation rec {
  dontBuild = true;
  buildInputs = [
    pkgs.dotnet-sdk_9
    pkgs.SDL2
    pkgs.openal
    pkgs.libGL
    supabase-cli
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/${pname}
    cp -rL . $out/lib/${pname}
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Smoke testing ${pname}"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.dotnet-sdk_9}/bin/dotnet run" >> $out/bin/${pname}
    chmod +x $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.dotnet-sdk_9
          supabase-cli
        ]
      } \
      --set LD_LIBRARY_PATH "${
        pkgs.lib.makeLibraryPath [
          pkgs.SDL2
          pkgs.openal
          pkgs.libGL
        ]
      }"
    runHook postInstall
  '';
  nativeBuildInputs = [
    pkgs.makeWrapper
    supabase-cli
  ];
  pname = "monogame_supabase_template";
  src = ./.;
  version = "0.0.0";
}
