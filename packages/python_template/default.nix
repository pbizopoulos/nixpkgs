{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python312Packages.buildPythonPackage rec {
  doInstallCheck = pkgs.stdenv.isLinux;
  installCheckPhase = ''
    runHook preInstallCheck
    DEBUG=1 "$out/bin/${pname}" | grep -F "test ... ok"
    runHook postInstallCheck
  '';
  installPhase = ''
    install -Dm755 ./main.py $out/bin/${pname}
  '';
  meta.mainProgram = pname;
  pname = builtins.baseNameOf src;
  pyproject = false;
  src = ./.;
  strictDeps = true;
  version = "0.0.0";
}
