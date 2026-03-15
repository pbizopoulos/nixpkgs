{
  pkgs ? import <nixpkgs> { },
}:
pkgs.buildGoModule rec {
  checkPhase = ''
    go test ./...
    go build -o ${pname}
    DEBUG=1 ./${pname}
  '';
  doCheck = true;
  meta.mainProgram = pname;
  nativeCheckInputs = [ ];
  pname = baseNameOf ./.;
  src = ./.;
  vendorHash = null;
  version = "0.0.0";
}
