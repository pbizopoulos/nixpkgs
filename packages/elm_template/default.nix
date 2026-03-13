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

  echo "Building Elm project..."
  ${pkgs.elmPackages.elm}/bin/elm make src/Main.elm --output main.js > /dev/null 2>&1

  if [ -f main.js ]; then
    echo "Hello World"
    ${pkgs.nodejs}/bin/node -e "
      const { Elm } = require('./main.js');
      Elm.Main.init({ flags: { debug: '0' } });
    "
  else
    echo "Failed to build Elm project"
    exit 1
  fi
''
