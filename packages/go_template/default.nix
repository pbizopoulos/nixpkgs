{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildGoModule rec {
  meta.mainProgram = pname;
  pname = baseNameOf ./.;
  src = ./.;
  vendorHash = null;
  version = "0.0.0";
}
