{
  pkgs ? import <nixpkgs> { },
}:
let
  pythonWithDeps = pkgs.python313.withPackages (ps: [
    ps.jinja2
    ps.matplotlib
    ps.pandas
  ]);
in
pkgs.python313Packages.buildPythonPackage rec {
  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    export PYTHON_LATEX_TEMPLATE_ASSETS="$PWD"
    python3 ./main.py "$TMPDIR/build"
    runHook postBuild
  '';
  installPhase = ''
    mkdir -p $out/bin $out/share/${pname}
    cp ./main.py $out/bin/${pname}
    cp ./ms.tex $out/share/${pname}/ms.tex
    cp ./ms.bib $out/share/${pname}/ms.bib
    cp "$TMPDIR/build/tmp/ms.pdf" $out/share/${pname}/ms.pdf
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.texliveFull
  ];
  pname = builtins.baseNameOf src;
  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --set PYTHON_LATEX_TEMPLATE_ASSETS $out/share/${pname} \
      --prefix PATH : ${pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.texliveFull
        pythonWithDeps
      ]}
  '';
  propagatedBuildInputs = with pkgs.python313Packages; [
    jinja2
    matplotlib
    pandas
  ];
  pyproject = false;
  src = ./.;
  version = "0.0.0";
}
