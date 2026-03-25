{
  inputs,
  pkgs,
  ...
}:
pkgs.testers.runNixOSTest rec {
  name = builtins.baseNameOf ./.;
  nodes.machine.environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.${name}
    pkgs.git
  ];
  testScript = ''
    machine.succeed("CANONICALIZATION_ROOT=. default .")
  '';
}
