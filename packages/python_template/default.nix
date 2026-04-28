{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python312Packages.buildPythonPackage rec {
  doInstallCheck = pkgs.stdenv.isLinux;
  installCheckPhase = ''
    runHook preInstallCheck
    HOME="$(mktemp -d)" DEBUG=1 coverage run --source="$src" "$src/main.py"
    coverage report
    HOME="$(mktemp -d)" DEBUG=1 pyinstrument "$src/main.py"
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
