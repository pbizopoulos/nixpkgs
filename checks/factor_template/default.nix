{ inputs, pkgs, ... }:
pkgs.testers.runNixOSTest rec {
  name = baseNameOf ./.;
  nodes.machine.environment.systemPackages = [ inputs.self.packages.${pkgs.stdenv.system}.${name} ];
  testScript = ''
    machine.succeed("DEBUG=1 ${name}")
  '';
}
