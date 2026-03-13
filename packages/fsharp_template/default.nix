{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [
    pkgs.dotnet-sdk_9
  ];
  buildPhase = ''
    export DOTNET_CLI_HOME=$TMPDIR
    export DOTNET_NOLOGO=1
    export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
    dotnet build -c Release -o out /p:TreatWarningsAsErrors=true
  '';
  installPhase = ''
    install -d $out/lib/fsharp
    cp -r out/* $out/lib/fsharp/
    install -d $out/bin
    makeWrapper ${pkgs.dotnet-runtime_9}/bin/dotnet $out/bin/${pname} \
      --add-flags "$out/lib/fsharp/fsharp.dll"
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
  ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
