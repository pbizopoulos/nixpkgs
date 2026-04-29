{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python312Packages.buildPythonPackage rec {
  doInstallCheck = pkgs.stdenv.isLinux;
  installCheckPhase = ''
    runHook preInstallCheck
    HOME="$(mktemp -d)" coverage erase
    HOME="$(mktemp -d)" DEBUG=1 coverage run --source="$src" "$src/main.py"
    HOME="$(mktemp -d)" coverage run --append --source="$src" "$src/main.py"
    coverage report --fail-under=100
    HOME="$(mktemp -d)" DEBUG=1 PYTHONWARNINGS=error pyinstrument "$src/main.py"
    runHook postInstallCheck
  '';
  installPhase = ''
    install -Dm755 ./main.py $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  nativeInstallCheckInputs = [
    pkgs.python312Packages.coverage
    pkgs.python312Packages.pyinstrument
  ];
  pname = builtins.baseNameOf src;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
