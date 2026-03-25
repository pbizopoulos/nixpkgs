{
  inputs,
  pkgs,
  ...
}:
let
  python-with-audit = pkgs.python313.withPackages (ps: [
    ps.coverage
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
    machine.succeed("DEBUG=1 ${python-with-audit}/bin/python3 -m coverage run $(which ${name})")
    machine.succeed("${python-with-audit}/bin/python3 -m coverage report")
  '';
}
