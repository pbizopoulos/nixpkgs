{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellApplication {
  name = builtins.baseNameOf ./.;
  runtimeInputs = [ ];
  text = builtins.readFile ./main.sh;
}
