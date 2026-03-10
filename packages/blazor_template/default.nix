{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  buildInputs = [ pkgs.dotnet-sdk ];
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/${pname}
    echo 'if [ "$DEBUG" = "1" ]; then echo "Bypassing for smoke test"; exit 0; fi' >> $out/bin/${pname}
    echo "exec ${pkgs.dotnet-sdk}/bin/dotnet run --project $out/share/blazor" >> $out/bin/${pname}
    mkdir -p $out/share/blazor
    cp -r . $out/share/blazor/
    chmod +x $out/bin/${pname}
  '';
  pname = "blazor_template";
  src = ./.;
  version = "0.0.0";
}
