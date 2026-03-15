{
  pkgs ? import <nixpkgs> { },
}:
pkgs.stdenv.mkDerivation rec {
  checkPhase = ''
    bash ${./.}/main.sh
    DEBUG=1 bash ${./.}/main.sh
  '';
  doCheck = true;
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 ${./.}/main.sh $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeCheckInputs = [ ];
  pname = baseNameOf ./.;
  src = ./.;
  version = "0.0.0";
}
