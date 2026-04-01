{
  inputs,
  pkgs,
  ...
}:
let
  python-with-audit = pkgs.python313.withPackages (ps: [
    ps.scalene
  ]);
in
pkgs.testers.runNixOSTest rec {
  name = "python_template";
  nodes.machine.environment.systemPackages = [
    inputs.self.packages.${pkgs.stdenv.system}.${name}
    pkgs.git
    python-with-audit
  ];
  testScript = ''
    machine.succeed("DEBUG=1 ${name}")
  '';
}
