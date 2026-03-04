{ inputs, pkgs, ... }:
pkgs.testers.runNixOSTest {
  name = "dart";
  nodes.machine.environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.dart-hello
  ];
  testScript = ''machine.succeed("DEBUG=1 dart-hello")'';
}
