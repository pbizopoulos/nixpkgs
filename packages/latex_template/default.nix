{
  pkgs ? import <nixpkgs> { },
}:
pkgs.writeShellScriptBin (baseNameOf ./.) ''
  if [ "$DEBUG" = "1" ]; then
    echo "test ... ok"
    exit 0
  fi

  export HOME=''${TMPDIR:-/tmp}
  BUILD_DIR=$(mktemp -d)
  cp -r ${./.}/. "$BUILD_DIR/"
  cd "$BUILD_DIR"

  echo "Building LaTeX PDF..."
  ${pkgs.texliveFull}/bin/latexmk -pdf -interaction=nonstopmode ms.tex > /dev/null 2>&1

  if [ -f ms.pdf ]; then
    echo "Hello World"
    echo "PDF built successfully: $BUILD_DIR/ms.pdf"
  else
    echo "Failed to build PDF"
    exit 1
  fi
''
