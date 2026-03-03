{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellApplication {
  name = builtins.baseNameOf ./.;
  runtimeInputs = [
    pkgs.git
    pkgs.imagemagick
  ];
  text = builtins.readFile ./main.sh;
}
