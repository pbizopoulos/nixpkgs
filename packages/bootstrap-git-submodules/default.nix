{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellApplication {
  name = builtins.baseNameOf ./.;
  runtimeInputs = [ pkgs.gh ];
  text = builtins.readFile ./main.sh;
}
