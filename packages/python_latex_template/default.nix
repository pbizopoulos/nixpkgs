{
  pkgs ? import <nixpkgs> { },
}:
let
  pythonDeps = [
    pkgs.python313Packages.jinja2
    pkgs.python313Packages.matplotlib
    pkgs.python313Packages.pandas
  ];
in
pkgs.python313Packages.buildPythonPackage rec {
  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    python3 ./main.py "$TMPDIR/build"
    runHook postBuild
  '';
  installPhase = ''
    install -Dm755 ./main.py $out/bin/${pname}
    install -Dm644 ./ms.tex $out/${pname}/ms.tex
    install -Dm644 ./ms.bib $out/${pname}/ms.bib
    install -Dm644 "$TMPDIR/build/tmp/ms.pdf" $out/${pname}/ms.pdf
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.texliveFull
  ];
  pname = builtins.baseNameOf src;
  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.coreutils
          (pkgs.python313.withPackages (_: pythonDeps))
          pkgs.texliveFull
        ]
      }
  '';
  propagatedBuildInputs = pythonDeps;
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
