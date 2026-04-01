{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellApplication {
  name = baseNameOf ./.;
  text = builtins.readFile ./main.sh;
}
