{
  inputs,
  pkgs,
  ...
}:
let
  name = builtins.baseNameOf ./.;
in
pkgs.testers.runNixOSTest rec {
  inherit name;
  nodes.machine.environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.${name}
  ];
  testScript = ''
    machine.succeed("DEBUG=1 ${name}")
  '';
}
