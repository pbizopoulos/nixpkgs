{
  pkgs ? import <nixpkgs> { },
}:
let
  name = baseNameOf ./.;
in
pkgs.writeShellApplication {
  inherit name;
  derivationArgs = {
    doInstallCheck = pkgs.stdenv.isLinux;
    installCheckPhase = ''
      runHook preInstallCheck
      "$out/bin/${name}" | grep -F "Hello World"
      runHook postInstallCheck
    '';
  };
  text = builtins.readFile ./main.sh;
}
