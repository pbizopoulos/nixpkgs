{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellApplication {
  name = baseNameOf ./.;
  runtimeInputs = [ ];
  text = builtins.readFile ./main.sh;
}
