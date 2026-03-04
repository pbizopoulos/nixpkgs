{ pkgs, ... }:
let
  mockPackage = pkgs.writeShellScriptBin name ''
    if [ "$DEBUG" == "1" ]; then
      echo "test math ... ok"
    else
      echo "Hello ${name}!"
    fi
  '';
  name = baseNameOf ./.;
in
pkgs.testers.runNixOSTest {
  inherit name;
  nodes.machine.environment.systemPackages = [ mockPackage ];
  testScript = ''machine.succeed("DEBUG=1 ${name}")'';
}
