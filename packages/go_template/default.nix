{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildGoModule rec {
  pname = "go_template";
  postInstall = "mv $out/bin/go-hello $out/bin/${pname}";
  src = ./.;
  vendorHash = null;
  version = "0.0.0";
}
