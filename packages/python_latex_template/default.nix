{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = baseNameOf ./.;
  pythonWithDeps = pkgs.python313.withPackages (ps: [
    ps.coverage
    ps.jinja2
    ps.matplotlib
    ps.pandas
  ]);
  runtimePath = pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.texliveFull
    pythonWithDeps
  ];
  wrapperScript = pkgs.writeShellScript "${pname}-wrapper" ''
    set -euo pipefail
    export PATH='${runtimePath}':"$PATH"
    export PYTHON_LATEX_TEMPLATE_ASSETS="@assetsDir@"
    resolve_source_root() {
      local candidate
      local current_dir="$PWD"
      if [ -n "''${CANONICALIZATION_ROOT:-}" ]; then
        candidate="$CANONICALIZATION_ROOT/packages/${pname}"
        if [ -f "$candidate/main.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
      fi
      while [ "$current_dir" != "/" ]; do
        candidate="$current_dir/packages/${pname}"
        if [ -f "$candidate/main.py" ]; then
          printf '%s\n' "$candidate"
          return 0
        fi
        current_dir="$(dirname "$current_dir")"
      done
      if [ -f "$PWD/main.py" ]; then
        printf '%s\n' "$PWD"
        return 0
      fi
      return 1
    }
    if [ "''${DEBUG:-0}" = "1" ]; then
      if source_root="$(resolve_source_root)"; then
        coverage_dir="$source_root/tmp/coverage"
        rm -rf "$coverage_dir"
        mkdir -p "$coverage_dir"
        cd "$source_root"
        export COVERAGE_FILE="$coverage_dir/.coverage"
        export PYTHON_LATEX_TEMPLATE_ASSETS="$source_root"
        export PYTHON_LATEX_TEMPLATE_OUTPUT_ROOT="$source_root"
        python3 -m coverage erase
        DEBUG=1 python3 -m coverage run --branch --include "$source_root/main.py" "$source_root/main.py"
        python3 -m coverage html -d "$coverage_dir/html"
        python3 -m coverage report | tee "$coverage_dir/summary.txt"
        exit 0
      fi
    fi
    exec "@wrappedBin@" "$@"
  '';
in
pkgs.stdenvNoCC.mkDerivation {
  inherit pname;
  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR"
    export PATH='${runtimePath}':"$PATH"
    export PYTHON_LATEX_TEMPLATE_ASSETS="$PWD"
    python3 ./main.py "$TMPDIR/build"
    runHook postBuild
  '';
  installPhase = ''
    install -Dm755 ./main.py "$out/bin/.${pname}-wrapped"
    install -Dm644 ./ms.tex "$out/share/${pname}/ms.tex"
    install -Dm644 ./ms.bib "$out/share/${pname}/ms.bib"
    install -Dm644 "$TMPDIR/build/tmp/ms.pdf" "$out/share/${pname}/ms.pdf"
    install -Dm755 ${wrapperScript} "$out/bin/${pname}"
    substituteInPlace "$out/bin/${pname}" \
      --replace-fail "@wrappedBin@" "$out/bin/.${pname}-wrapped" \
      --replace-fail "@assetsDir@" "$out/share/${pname}"
  '';
  meta.mainProgram = pname;
  nativeBuildInputs = [
    pkgs.texliveFull
    pythonWithDeps
  ];
  src = ./.;
  version = "0.0.0";
}
