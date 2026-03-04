{ pkgs, ... }:
let
  mockClojure = pkgs.writeShellScriptBin "clojure" ''
    if [ "$DEBUG" == "1" ]; then
      echo "test math ... ok"
    else
      echo "Hello Clojure!"
    fi
  '';
in
pkgs.testers.runNixOSTest {
  name = baseNameOf ./.;
  nodes.machine.environment.systemPackages = [ mockClojure ];
  testScript = ''machine.succeed("DEBUG=1 clojure")'';
}
