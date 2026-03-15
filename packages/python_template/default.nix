{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python3Packages.buildPythonPackage rec {
  checkPhase = ''
    python3 main.py
    DEBUG=1 python3 main.py
  '';
  doCheck = true;
  installPhase = ''
    install -Dm755 ./main.py $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeCheckInputs = [ ];
  pname = baseNameOf ./.;
  propagatedBuildInputs = [
    pkgs.python3Packages.termcolor
  ];
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
