{
  pkgs ? import <nixpkgs> { },
}:
pkgs.python313Packages.buildPythonPackage rec {
  installPhase = ''
    mkdir -p $out/bin
    cp ./main.py $out/bin/.${pname}-wrapped
    makeWrapper ${pkgs.python313}/bin/python $out/bin/${pname} \
      --add-flags "$out/bin/.${pname}-wrapped" \
      --prefix PYTHONPATH : "$PYTHONPATH"
    cp -r ./prm/ $out/bin/
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  pname = "python_alphabetize";
  propagatedBuildInputs = [
    pkgs.python313Packages.fire
    pkgs.python313Packages.libcst
  ];
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
