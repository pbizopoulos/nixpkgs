{
  pkgs ? import <nixpkgs> { },
}:
let
  pythonDeps = [
    pkgs.python313Packages.matplotlib
    pkgs.python313Packages.pandas
  ];
in
pkgs.python313Packages.buildPythonPackage rec {
  buildPhase = ''
    runHook preBuild
    mkdir -p "$TMPDIR/build"
    (
      cd "$TMPDIR/build"
      python3 "$src/main.py"
      cd tmp
      latexmk -pdf ms.tex >/dev/null 2>&1
    )
    runHook postBuild
  '';
  installPhase = ''
        mkdir -p $out/bin
        install -Dm644 ./main.py $out/${pname}/main.py
        install -Dm644 ./ms.tex $out/${pname}/ms.tex
        install -Dm644 ./ms.bib $out/${pname}/ms.bib
        install -Dm644 "$TMPDIR/build/tmp/ms.pdf" $out/ms.pdf
        cat > $out/bin/${pname} <<EOF
    #!/usr/bin/env bash
    set -euo pipefail
    destination_root="/tmp/python_latex_template-\$(id -u)"
    mkdir -p "\$destination_root"
    rm -rf "\$destination_root/tmp"
    cd "\$destination_root"
    python3 "$out/${pname}/main.py"
    cd tmp
    latexmk -pdf ms.tex >/dev/null 2>&1
    echo "PDF: \$destination_root/tmp/ms.pdf"
    EOF
        chmod +x $out/bin/${pname}
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
